use std::{os::raw::c_int, time::Instant};
use tarantool::tuple::{FunctionCtx};
use serde::{Deserialize, Serialize};
use tarantool::{space::Space, index::IteratorType};

enum LuaResult<T: Serialize> {
  Ok(T),
  Err(String),
}

impl<T: Serialize> LuaResult<T> {
  fn send(self, ctx: FunctionCtx, start_time: Instant) -> c_int {
    match self {
      Self::Ok(value) => {
        ctx.return_mp(&true).ok();
        ctx.return_mp(&value).ok();
      },
      Self::Err(error) => {
        ctx.return_mp(&false).ok();
        ctx.return_mp(&error).ok();
      }
    }
    let duration = Instant::now() - start_time;
    ctx.return_mp(&duration.as_secs_f64()).ok();
    0
  }
}

#[derive(Serialize, Deserialize)]
struct Args {
    t: f64,
}

#[derive(Serialize, Deserialize)]
struct Row {
    user_id: u32,
    id: String,
    t: f64,
    pack: RowPack,
}

#[derive(Serialize, Deserialize)]
struct RowPack {
    num: u32,
    str: String,
}

#[derive(Serialize, Deserialize)]
pub(crate) struct RowResult {
    user_id: u32,
    id: String,    
    num: u32,
    str: String,
}


fn orders() -> LuaResult<Vec<RowResult>> {

    let name = "orders";
    
    let space = match Space::find(name){
        None => {
            return LuaResult::Err(format!("Can't find space [{}]", name));
        }
        Some(space) => space,
    };

    let rows = match space.select(IteratorType::GE, &(1u32,)) {
        Ok(rows) => rows,
        Err(e) => {
            return LuaResult::Err(format!("Can't select. {:?}", e));
        }
    };

    let mut result = vec![];
    for row in rows {
        let row: Row = match row.into_struct() {
            Ok(row) => row,
            Err(e) => {
                return LuaResult::Err(format!("Deserialize error {:?}", e));
            }
        };
        result.push(RowResult{
            user_id: row.user_id,
            id:row.id,
            num:row.pack.num * 10,
            str:row.pack.str,
        });
    }

    LuaResult::Ok(result)
}


#[no_mangle]
pub extern "C" fn select(ctx: FunctionCtx) -> c_int {
  let start_time = Instant::now();
  orders().send(ctx, start_time)
}
