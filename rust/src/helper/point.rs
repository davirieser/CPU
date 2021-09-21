use crate::helper::traits::ToSvg;

use core::marker::Copy;
use std::clone::Clone;
use std::cmp::PartialEq;
use std::default::Default;
use std::fmt::{self, Debug, Display};
use std::ops::{Add, Sub};

pub struct Point {
    pub(crate) x: usize,
    pub(crate) y: usize,
}

impl Point {
    pub fn new(x: usize, y: usize) -> Self {
        Point { x, y }
    }
    pub fn display(&self) -> String {
        format!("({}, {})", self.x, self.y)
    }
    pub fn x(&self) -> usize {
        self.x
    }
    pub fn y(&self) -> usize {
        self.y
    }
    pub fn add_y(&self, other: usize) -> Self {
        Self {
            x: self.x,
            y: self.y + other,
        }
    }
    pub fn sub_y(&self, other: usize) -> Self {
        Self {
            x: self.x,
            y: self.y - other,
        }
    }
}

impl Default for Point {
    fn default() -> Self {
        Point::new(0, 0)
    }
}

impl PartialEq for Point {
    fn eq(&self, other: &Self) -> bool {
        (self.x == other.x) && (self.y == other.y)
    }
}

impl Copy for Point {}

impl Clone for Point {
    fn clone(&self) -> Self {
        Point {
            x: self.x,
            y: self.y,
        }
    }
}

impl Add<Point> for Point {
    type Output = Self;

    fn add(self, other: Point) -> Self {
        Self {
            x: self.x + other.x,
            y: self.y + other.y,
        }
    }
}

impl Add<[usize; 2]> for Point {
    type Output = Self;

    fn add(self, other: [usize; 2]) -> Self {
        Self {
            x: self.x + other[0],
            y: self.y + other[1],
        }
    }
}

impl Sub<Point> for Point {
    type Output = Self;

    fn sub(self, other: Point) -> Self {
        Self {
            x: self.x - other.x,
            y: self.y - other.y,
        }
    }
}

impl Sub<[usize; 2]> for Point {
    type Output = Self;

    fn sub(self, other: [usize; 2]) -> Self {
        Self {
            x: self.x - other[0],
            y: self.y - other[1],
        }
    }
}

impl Debug for Point {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        return write!(f, "x=\"{}\" y=\"{}\"", self.x, self.y);
    }
}

impl Display for Point {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        return write!(f, "({} {})", self.x, self.y);
    }
}

#[derive(Clone, PartialEq)]
pub enum Path {
    MoveTo(Point, bool),
    LineTo(Point, bool),
    ClosePath,
    BezierCurve([Point; 3], bool),
}

impl Path {
    pub fn new_move_to_path(p: Point) -> Self {
        Path::MoveTo(p, false)
    }
    pub fn new_line_to_path(p: Point) -> Self {
        Path::LineTo(p, false)
    }
    pub fn new_close_path() -> Self {
        Path::ClosePath
    }
    pub fn new_curve_path(p: [Point; 3]) -> Self {
        if (p[0] == p[1]) || (p[1] == p[2]) {
            return Path::LineTo(p[1], false);
        }
        Path::BezierCurve(p, false)
    }
    pub fn get_point(&self) -> Option<&Point> {
        match self {
            Path::MoveTo(point, _) => Some(point),
            Path::LineTo(point, _) => Some(point),
            Path::ClosePath => None,
            Path::BezierCurve(point, _) => Some(&point[0]),
        }
    }
    pub fn set_positioning(self, positioning: bool) -> Self {
        match self {
            Path::MoveTo(point, _) => Path::MoveTo(point, positioning),
            Path::LineTo(point, _) => Path::LineTo(point, positioning),
            Path::BezierCurve(points, _) => Path::BezierCurve(points, positioning),
            x => x,
        }
    }
    pub fn set_relative(self) -> Self {
        self.set_positioning(true)
    }
    pub fn set_absolute(self) -> Self {
        self.set_positioning(false)
    }
}

impl Display for Path {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Path::MoveTo(point, relative) => {
                let command;
                if *(relative) {
                    command = 'm';
                } else {
                    command = 'M';
                }
                return write!(f, "{} {} {}", command, point.x, point.y,);
            }
            Path::LineTo(point, relative) => {
                let command;
                if *(relative) {
                    command = 'l';
                } else {
                    command = 'L';
                }
                return write!(f, "{} {} {}", command, point.x, point.y,);
            }
            Path::ClosePath => {
                return write!(f, "Z");
            }
            Path::BezierCurve(points, relative) => {
                let command;
                if *(relative) {
                    command = 'c';
                } else {
                    command = 'C';
                }
                return write!(
                    f,
                    "{} {} {} {} {} {} {}",
                    command,
                    points[0].x,
                    points[0].y,
                    points[1].x,
                    points[1].y,
                    points[2].x,
                    points[2].y,
                );
            }
        }
    }
}

impl ToSvg for Path {
    fn to_svg(&self) -> String {
        match self {
            Path::MoveTo(point, relative) => {
                let command;
                if *(relative) {
                    command = 'm';
                } else {
                    command = 'M';
                }
                return format!("{} {} {}", command, point.x, point.y,);
            }
            Path::LineTo(point, relative) => {
                let command;
                if *(relative) {
                    command = 'l';
                } else {
                    command = 'L';
                }
                return format!("{} {} {}", command, point.x, point.y,);
            }
            Path::ClosePath => "Z".to_string(),
            Path::BezierCurve(points, relative) => {
                let command;
                if *(relative) {
                    command = 'c';
                } else {
                    command = 'C';
                }
                return format!(
                    "{} {} {} {} {} {} {}",
                    command,
                    points[0].x,
                    points[0].y,
                    points[1].x,
                    points[1].y,
                    points[2].x,
                    points[2].y,
                );
            }
        }
    }
    fn to_svg_indent(&self, indent: usize) -> String {
        match self {
            Path::MoveTo(point, relative) => {
                let command;
                if *(relative) {
                    command = 'm';
                } else {
                    command = 'M';
                }
                return format!("{} {} {}", command, point.x, point.y,);
            }
            Path::LineTo(point, relative) => {
                let command;
                if *(relative) {
                    command = 'l';
                } else {
                    command = 'L';
                }
                return format!("{} {} {}", command, point.x, point.y,);
            }
            Path::ClosePath => "Z".to_string(),
            Path::BezierCurve(points, relative) => {
                let command;
                if *(relative) {
                    command = 'c';
                } else {
                    command = 'C';
                }
                return format!(
                    "{} {} {} {} {} {} {}",
                    command,
                    points[0].x,
                    points[0].y,
                    points[1].x,
                    points[1].y,
                    points[2].x,
                    points[2].y,
                );
            }
        }
    }
}
