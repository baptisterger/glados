(module
(func $main
  (result i32)
  (local f32)
  (local i32)
  (local f32)
  (local i32)
  (local i32)
  f32.const 3.14
  local.set 0
  i32.const 2
  local.set 1
  local.get 0
  local.get 1
  i32.mul
  f32.const 1.0
  i32.add
  local.set 2
  i32.const 1
  local.set 3
  i32.const 0
  local.set 4
  local.get 3
  i32.const 1
  i32.eq
  if
  i32.const 1
  return
else
  i32.const -1
  return
end
  i32.const 0
  return
)

  (export "main" (func $main))
)
