use crate::helper::point::{Path, Point};

use std::fmt::{self, Debug, Display};

pub trait ToSvg {
    fn to_svg(&self) -> String;
    fn to_svg_indent(&self, indent: usize) -> String;
    fn calculate_viewbox(&self) -> [Point; 2] {
        [Point::new(0, 0), Point::new(0, 0)]
    }
}

pub trait Component<T: ToSvg> {
    fn generate_model(&self, start_pos: Point, scale: usize) -> String;
    fn generate_output(&self) -> String;
}
