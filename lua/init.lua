obj = {}

  package.cpath  = package.cpath .. ";/home/avv/projects/rust/tnt_rust_test/demo/target/release/?.so"
  package.path = package.path .. ";/home/avv/projects/rust/tnt_rust_test/lua/?.lua"


  net     = require('net.box')
  fiber   = require('fiber')
  uuid    = require('uuid')
  clock   = require('clock')
  log     = require('log')
  rust    = require('net.box').connect(box.cfg.listen)


  obj.test = reload('test')


  -- --------------------------------------------------------------------
  --  spaces
  -- --------------------------------------------------------------------
  box.session.su('admin')

  local orders = box.schema.create_space('orders', {
    format = {
      { name = 'user_id', type = 'number'},
      { name = 'id',      type = 'string'},
      { name = 't',       type = 'number'},
      { name = 'pack',    type = 'any'},
    },
    if_not_exists = true
  })

  orders:create_index('userid_id', {type='tree', parts={'user_id','id'}, if_not_exists = true})
  orders:create_index('t', {type='tree', parts={'t'}, if_not_exists = true, unique=false})

  

  -- --------------------------------------------------------------------
  --  rust
  -- --------------------------------------------------------------------

  local libs = {'libdemo', 'libdemo.select'}
  for _,name in pairs(libs) do
    box.schema.func.drop(name, {if_exists=true})
    box.schema.func.create(name, {language = 'C', if_not_exists = true})
    box.schema.user.grant('guest', 'read, write, execute, create, alter, drop, usage, session', 'universe', '', {
      if_not_exists = true
    })
  end



return obj