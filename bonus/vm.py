import sys
from wasmtime import Store, Module, Instance, Func, FuncType, ValType, ExportType

def host_print_i32(arg: int):
    print(arg)

def host_print_f32(arg: float):
    print(arg)

class WasmRunner:
    def __init__(self, wasm_or_wat_path):
        self.store = Store()
        self.module = Module.from_file(self.store.engine, wasm_or_wat_path)

        print_i32_type = FuncType([ValType.i32()], [])
        self.host_print_i32_func = Func(self.store, print_i32_type, host_print_i32)

        print_f32_type = FuncType([ValType.f32()], [])
        self.host_print_f32_func = Func(self.store, print_f32_type, host_print_f32)

        imports = []
        for import_type in self.module.imports:
            if import_type.module == "env" and import_type.name == "print":
                if isinstance(import_type.type, FuncType):
                    if import_type.type.params == [ValType.f32()]:
                        imports.append(self.host_print_f32_func)
                    elif import_type.type.params == [ValType.i32()]:
                        imports.append(self.host_print_i32_func)
                    else:
                        raise Exception(f"Unsupported print function type: {import_type.type.params}")
                else:
                    raise Exception(f"Unsupported import type: {import_type.type}")
            else:
                raise Exception(f"Unknown import: {import_type.module}.{import_type.name}")

        self.instance = Instance(self.store, self.module, imports)

    def run(self):
        main_func = self.instance.exports(self.store)["main"]
        if main_func:
            result = main_func(self.store)
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
