(module
  (import "env" "print" (func $print (param f32)))
  (import "env" "print" (func $print_i32 (param i32)))
  
  (func $main (export "main")
    (local $a f32)
    (local $b i32)
    (local $c f32)
    (local $ok i32)
    (local $fail i32)
    
    ;; float a = 3.14;
    f32.const 3.14
    local.set $a
    
    ;; int b = 2;
    i32.const 2
    local.set $b
    
    ;; float c = a * b + 1.0;
    local.get $a
    local.get $b
    f32.convert_i32_s
    f32.mul
    f32.const 1.0
    f32.add
    local.set $c
    
    ;; print(c);
    local.get $c
    call $print
    
    ;; bool ok = true;
    i32.const 1
    local.set $ok
    
    ;; bool fail = false;
    i32.const 0
    local.set $fail
    
    ;; if (ok == true) { print(1); } else { print(0); }
    local.get $ok
    i32.const 1
    i32.eq
    if
      i32.const 1
      call $print_i32
    else
      i32.const 0
      call $print_i32
    end
  )
)