
use bitflags::bitflags;

#[derive(debug)]
bitflags! {
    struct ALU_CTRL : u32 {
        const AND = 0x1;
        const OR = 0x2;
        const XOR = 0x4;
        const NOT_A = 0x8;
        const NOT_B = 0x10;
        const ADD = 0x20;
        const SUB = 0x40;
        const SHIFT = 0x80;
        const PARITY = 0x100;
    }
}

#[derive(debug)]
bitflags! {
    struct ALU_FLAGS : u32 {
        const CYC_BUFFER = 0x1;
        const REL_JUMPS = 0x2;
        const CARRY_IN = 0x04;
    }
}

#[derive(debug)]
bitflags! {
    struct ALU_STATUS : u32 {
        const CARRY_OUT = 0x1;
        const ZERO = 0x2;
        const OVERFLOW = 0x04;
        const EVEN = 0x8;
        const ODD = 0x10;
        const SIGN = 0x20;
    }
}

fn ALU (
    ctrl : &ALU_CTRL,
    flags : &ALU_FLAGS,
    op1 : &u32,
    op2 : &u32,
    ctrl_bus : &mut CTRL_BUS,
    data_bus : &mut DATA_BUS,
    status_out : ALU_STATUS
) {

    match ctrl {
        ALU_CTRL::ADD => {
            return (op1 + op2) & ((1 << 24) - 1)
        },
        _ => {
            return 0x0;
        }
    }

}

const REG_WIDTH : usize = 32;
const BUS_WIDTH : usize = REG_WIDTH;

#[derive(Copy, Clone)]
enum Logic {
    High,
    Low,
    HighImp,
    DontCare,
    Unknown
}

// impl Copy for Logic {
//     fn copy() {
//         ma
//     }
// }

// TODO Rename
type BUS = [Logic; BUS_WIDTH];

trait INOUT {
    fn default() -> Self;
    fn high_imp() -> Self;
    fn unknown() -> Self;
    fn high() -> Self;
    fn low() -> Self;
}

impl INOUT for BUS {
    fn default() -> Self {
        [Logic::Unknown; BUS_WIDTH]
    }
    fn high_imp() -> Self {
        [Logic::HighImp; BUS_WIDTH]
    }
    fn unknown() -> Self {
        [Logic::Unknown; BUS_WIDTH]
    }
    fn high() -> Self {
        [Logic::High; BUS_WIDTH]
    }
    fn low() -> Self {
        [Logic::High; BUS_WIDTH]
    }
}

struct Bus {
    value: BUS,
    set: bool
}

impl Bus {
    pub fn write(&mut self, value: BUS) -> bool {
        if self.set {
            self.value = BUS::unknown();
            self.set = true;
            return false;
        }
        self.value = value;
        true
    }
    pub fn read(&mut self) -> BUS {
        return self.value;
    }
    pub fn new_cycle(&mut self) {
        self.value = BUS::unknown();
        self.set = false
    }
}

fn test(x : &mut u32) {

    *x = 10;

}

fn main() {

    let mut x : u32 = 6;

    test(&mut x);

    print!("{}", x);

}
