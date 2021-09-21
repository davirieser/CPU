#![allow(unused, dead_code, non_snake_case)]

use bitflags::bitflags;

mod helper;
use crate::helper::{
    point::{Path, Point},
    traits::{Component, ToSvg},
};

bitflags! {
    struct AluCtrl : u32 {
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

bitflags! {
    struct AluFlags : u32 {
        const CYC_BUFFER = 0x1;
        const REL_JUMPS = 0x2;
        const CARRY_IN = 0x04;
    }
}

bitflags! {
    struct AluStatus : u32 {
        const CARRY_OUT = 0x1;
        const ZERO = 0x2;
        const OVERFLOW = 0x04;
        const EVEN = 0x8;
        const ODD = 0x10;
        const SIGN = 0x20;
    }
}

fn Alu(
    ctrl: &AluCtrl,
    flags: &AluFlags,
    op1: &usize,
    op2: &usize,
    ctrl_bus: &mut CtrlBus,
    data_bus: &mut DataBus,
    status_out: AluStatus,
) {
    let result: usize;

    match *ctrl {
        AluCtrl::ADD => result = (op1 + op2) & ((1 << 24) - 1),
        _ => {
            return;
        }
    }

    *data_bus = result;
}

const REG_WIDTH: usize = 32;
const BUS_WIDTH: usize = REG_WIDTH;

#[derive(Copy, Clone)]
#[allow(unused)]
enum Logic {
    High,
    Low,
    HighImp,
    DontCare,
    Unknown,
}

type CtrlBus = [usize; REG_WIDTH];
type DataBus = usize;

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
    set: bool,
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

fn test(x: &mut u32) {
    *x = 10;
}

fn main() {
    let mut x: u32 = 6;

    test(&mut x);

    print!("{}", x);
}
