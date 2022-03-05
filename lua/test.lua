local obj={}


-- ----------------------------------------------------------------------------
--  Подготовка данных
-- ----------------------------------------------------------------------------
function obj.create_orders()

  local c0  = clock.time()
  local i   = 0

  box.space.orders:truncate()

  box.begin()

  for j = 1, 99999 do

    i = i + 1
    if i > 999 then
      box.commit()
      fiber.sleep(0)
      box.begin()
    end

    box.space.orders:replace{
      math.random(1, 99),
      uuid:str(),
      clock.time(),
      {
        num = math.random(1, 99),
        str = string.format('s-%s', math.random(1, 99))
      }
    }
  end
  box.commit()

  return { t = clock.time() - c0, cnt = box.space.orders:count() }
end





-- ----------------------------------------------------------------------------
--  Время выполнения lua
-- ----------------------------------------------------------------------------
function obj.start()

  -- lua
  local c1 = clock.time()
  local rs = {}
  for _,v in box.space.orders.index.t:pairs({1},{iterator='ge'}) do
    table.insert(rs, {v.user_id, v.id, v.pack.num, v.pack.str})
  end
  local t1 = clock.time() - c1

  -- rust
  local c2  = clock.time()
  local rs2 = rust:call('libdemo.select')
  local t2  = clock.time() - c1

  return {lua = {time = t1}, rust = {time_rust_proc=rs2[3], time = t2} }
end





return obj