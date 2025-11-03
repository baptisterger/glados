import sys
from wasmtime import Store, Module, Instance, Func, FuncType, ValType, Linker

class WasmRunner:
    def __init__(self, wasm_or_wat_path):
        self.store = Store()
        self.module = Module.from_file(self.store.engine, wasm_or_wat_path)
        self.linker = Linker(self.store.engine)


        def host_print_i32(arg: int):
            print(arg)

        def host_print_f32(arg: float):
            print(arg)

        def host_print_string(address: int, length: int):
            memory = self.instance.exports(self.store).get("memory")
            if memory is None:
                raise TypeError("WebAssembly module must export a memory to print strings.")
            
            data = memory.read(self.store, address, length)
            
            print(data.decode('utf-8'))

        # --- Linking ---

        print_i32_type = FuncType([ValType.i32()], [])
        print_f32_type = FuncType([ValType.f32()], [])
        print_string_type = FuncType([ValType.i32(), ValType.i32()], [])

        self.linker.define_func("env", "print_i32", print_i32_type, host_print_i32)
        self.linker.define_func("env", "print_f32", print_f32_type, host_print_f32)
        self.linker.define_func("env", "print_str", print_string_type, host_print_string)
        
        self.instance = self.linker.instantiate(self.store, self.module)

    def run(self):
        main_func = self.instance.exports(self.store).get("main")
        if main_func is not None:
            result = main_func(self.store)
            if result is not None:
                print(f"main() returned: {result}")
        else:
            print("Error: 'main' function not found in WASM module.")

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: bonus/vm.py <file.wasm or file.wat>")
        sys.exit(1)

    wasm_or_wat_file = sys.argv[1]
    runner = WasmRunner(wasm_or_wat_file)
    runner.run()
