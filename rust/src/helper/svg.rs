use crate::helper::{point::Point, traits::ToSvg};

use std::fmt::{self, Display};
pub struct Svg {
    components: Vec<Box<dyn ToSvg>>,
    view_box: [Point; 2],
}

impl Svg {
    pub fn new(comp: Vec<Box<dyn ToSvg>>) -> Self {
        let view_box: [Point; 2] = [Point::new(0, 0), Point::new(0, 0)];
        Svg {
            components: comp,
            view_box,
        }
    }
    pub fn push(&mut self, item: Box<dyn ToSvg>) {
        self.components.push(item);
    }
    pub fn set_view_box(&mut self, view_box: [Point; 2]) {
        self.view_box = view_box;
    }
}

impl ToSvg for Svg {
    fn to_svg(&self) -> String {
        let mut string = format!(
            "<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" viewBox=\"{} {}\">\r\n",
            self.view_box[0],
            self.view_box[1]
        );

        self.components
            .iter()
            .for_each(|x| string.push_str(&(x.to_svg_indent(1) + "\r\n")));

        string.push_str("</svg>");
        string
    }
    fn to_svg_indent(&self, indent: usize) -> String {
        let indent_string = "\t".repeat(indent);

        let mut string = format!(
            "{}<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" viewBox=\"{} {}\">\r\n",
            indent_string,
            self.view_box[0],
            self.view_box[1]
        );

        self.components
            .iter()
            .for_each(|x| string.push_str(&(x.to_svg_indent(indent + 1) + "\r\n")));

        string.push_str(&indent_string);
        string.push_str("</svg>");

        string
    }
}

impl Display for Svg {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        return write!(f, "{}", self.to_svg());
    }
}
