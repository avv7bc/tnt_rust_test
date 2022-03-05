# Тест для сравнения скорости работы lua и rust программы
## Конфигурация tarantool

```lua
local console = require('console')

-- tarantool configuration
box.cfg {
	    wal_mode = 'write',
        listen = 3001,
        log_level = 5,
        too_long_threshold = 0.5,
        log = '/var/log/tarantool/box.log',
        log_format = 'plain',
        memtx_max_tuple_size =100 * 1024 * 1024, --100Mb
        memtx_memory = 5 * 1024 * 1024 * 1024, --5Gb
        checkpoint_interval = 60, -- snapshot every 60 sec
        checkpoint_count = 3, --store 3 last snapshot's
        force_recovery = true,
        custom_proc_title = 'box',
        pid_file  = 'box.pid'
      }

        box.once("schema", function()
            box.schema.user.create('dev', {password = '12345'})
            box.schema.user.grant('dev', 'read,write,execute','universe', nil, {if_not_exists = true})
            box.schema.user.grant('dev', 'replication', nil, nil, {if_not_exists = true})
        end)

        function reload(proc)
           package.loaded[proc]=nil
           return require(proc)
        end
    
```

## 0. Копируем проект на /home/user/projects/

    
## 1. Запуск проекта lua

```lua  
  app = reload('/home/user/projects/tnt_rust_test/lua/init')
  
```

## 2. Создание тестовых данных

```lua  
  app.test.create_orders()
  
```

## 3. Сборка demo

```rust  
  cargo build --release
  
```


## 4. Запуск теста

```lua  
  app.test.start()
  
```


## 5. Результат
```lua  

localhost:3001> app.test.start()
lua:
    time: 0.24526524543762 -- время выполнения lua кода
  rust:
    time_rust_proc: 0.69454182  -- время выполнения rust кода (по расчету rust)
    time: 1.0144066810608 -- время выполнения rust кода (по расчету lua)
```
