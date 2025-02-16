import Builder from '../Builder.js'

const b = new Builder();
b.Type().End()
    .Function().End()
    .Code()
    .Function({ params: ["f32"], ret: "f32" }, [])
    .GetLocal(0)
    .F32Trunc()
    .End()

    .Function({ params: ["f64"], ret: "f64" }, [])
    .GetLocal(0)
    .F64Trunc()
    .End()

const bin = b.WebAssembly()
bin.trim();
testWasmModuleFunctions(bin.get(), 2,
                        [[{ type: "f32", value: "-0x0p+0" }, [{ type: "f32", value: "-0x0p+0" }]],
                         [{ type: "f32", value: "0x0p+0" }, [{ type: "f32", value: "0x0p+0" }]],
                         [{ type: "f32", value: "-0x0p+0" }, [{ type: "f32", value: "-0x1p-149" }]],
                         [{ type: "f32", value: "0x0p+0" }, [{ type: "f32", value: "0x1p-149" }]],
                         [{ type: "f32", value: "-0x0p+0" }, [{ type: "f32", value: "-0x1p-126" }]],
                         [{ type: "f32", value: "0x0p+0" }, [{ type: "f32", value: "0x1p-126" }]],
                         [{ type: "f32", value: "-0x0p+0" }, [{ type: "f32", value: "-0x1p-1" }]],
                         [{ type: "f32", value: "0x0p+0" }, [{ type: "f32", value: "0x1p-1" }]],
                         [{ type: "f32", value: "-0x1p+0" }, [{ type: "f32", value: "-0x1p+0" }]],
                         [{ type: "f32", value: "0x1p+0" }, [{ type: "f32", value: "0x1p+0" }]],
                         [{ type: "f32", value: "-0x1.8p+2" }, [{ type: "f32", value: "-0x1.921fb6p+2" }]],
                         [{ type: "f32", value: "0x1.8p+2" }, [{ type: "f32", value: "0x1.921fb6p+2" }]],
                         [{ type: "f32", value: "-0x1.fffffep+127" }, [{ type: "f32", value: "-0x1.fffffep+127" }]],
                         [{ type: "f32", value: "0x1.fffffep+127" }, [{ type: "f32", value: "0x1.fffffep+127" }]],
                         [{ type: "f32", value: "-infinity" }, [{ type: "f32", value: "-infinity" }]],
                         [{ type: "f32", value: "infinity" }, [{ type: "f32", value: "infinity" }]],
                        ],

                        [[{ type: "f64", value: "-0x0p+0" }, [{ type: "f64", value: "-0x0p+0" }]],
                         [{ type: "f64", value: "0x0p+0" }, [{ type: "f64", value: "0x0p+0" }]],
                         [{ type: "f64", value: "-0x0p+0" }, [{ type: "f64", value: "-0x0.0000000000001p-1022" }]],
                         [{ type: "f64", value: "0x0p+0" }, [{ type: "f64", value: "0x0.0000000000001p-1022" }]],
                         [{ type: "f64", value: "-0x0p+0" }, [{ type: "f64", value: "-0x1p-1022" }]],
                         [{ type: "f64", value: "0x0p+0" }, [{ type: "f64", value: "0x1p-1022" }]],
                         [{ type: "f64", value: "-0x0p+0" }, [{ type: "f64", value: "-0x1p-1" }]],
                         [{ type: "f64", value: "0x0p+0" }, [{ type: "f64", value: "0x1p-1" }]],
                         [{ type: "f64", value: "-0x1p+0" }, [{ type: "f64", value: "-0x1p+0" }]],
                         [{ type: "f64", value: "0x1p+0" }, [{ type: "f64", value: "0x1p+0" }]],
                         [{ type: "f64", value: "-0x1.8p+2" }, [{ type: "f64", value: "-0x1.921fb54442d18p+2" }]],
                         [{ type: "f64", value: "0x1.8p+2" }, [{ type: "f64", value: "0x1.921fb54442d18p+2" }]],
                         [{ type: "f64", value: "-0x1.fffffffffffffp+1023" }, [{ type: "f64", value: "-0x1.fffffffffffffp+1023" }]],
                         [{ type: "f64", value: "0x1.fffffffffffffp+1023" }, [{ type: "f64", value: "0x1.fffffffffffffp+1023" }]],
                         [{ type: "f64", value: "-infinity" }, [{ type: "f64", value: "-infinity" }]],
                         [{ type: "f64", value: "infinity" }, [{ type: "f64", value: "infinity" }]],
                        ],
                       );
