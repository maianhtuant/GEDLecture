from manim import *

class SolveEquation(Scene):
    def construct(self):
        # Step 1: Show original equation (centered)
        eq1 = MathTex(r"x", r"+", r"10", r"=", r"5", font_size=48)
        self.play(Write(eq1))
        self.wait(3)  # Time to read: "Let's solve x + 10 = 5"

        # Move eq1 up first, THEN position -10 under it
        self.play(eq1.animate.shift(UP * 0.5))

        # Step 2: Create -10 under "10" and "5"
        minus10_left = MathTex(r"-10", font_size=32)
        minus10_right = MathTex(r"-10", font_size=32)
        minus10_left.next_to(eq1[2], DOWN)
        minus10_right.next_to(eq1[4], DOWN)

        self.play(Write(minus10_left), Write(minus10_right))
        self.wait(1)

        # Single underline spanning from x all the way to 5
        y_uline = minus10_left.get_bottom()[1] - 0.08
        uline_left = Line(
            start=np.array([eq1[0].get_left()[0], y_uline, 0]),
            end=np.array([eq1[4].get_right()[0], y_uline, 0]),
            color=WHITE, stroke_width=2
        )
        uline_right = uline_left  # single line, kept as alias for VGroup compatibility
        self.play(Create(uline_left))
        self.wait(0.5)

        # Bold flash on -10 under 5
        self.play(
            Flash(minus10_right, color=YELLOW, flash_radius=0.5, num_lines=12, line_length=0.2),
            minus10_right.animate.set_color(YELLOW).set_stroke(color=YELLOW, width=3)
        )
        self.play(Indicate(minus10_right, color=YELLOW, scale_factor=1.6))
        self.wait(0.5)

        # Write -5 right after flash, before cancel
        result_neg5_minus = MathTex(r"-", font_size=28)
        result_neg5_num = MathTex(r"5", font_size=48)
        result_neg5_num.next_to(result_neg5_minus, RIGHT, buff=0.05)
        result_neg5 = VGroup(result_neg5_minus, result_neg5_num)
        result_neg5.move_to([minus10_right.get_x(), minus10_left.get_bottom()[1] - 0.65, 0])
        self.play(Write(result_neg5))
        self.wait(0.5)

        # Draw cancel lines (\ direction, one per number)
        cancel_10 = Line(
            start=eq1[2].get_corner(UL) + LEFT * 0.05 + UP * 0.05,
            end=eq1[2].get_corner(DR) + RIGHT * 0.05 + DOWN * 0.05,
            color=RED, stroke_width=4
        )
        cancel_minus10 = Line(
            start=minus10_left.get_corner(UL) + LEFT * 0.05 + UP * 0.05,
            end=minus10_left.get_corner(DR) + RIGHT * 0.05 + DOWN * 0.05,
            color=RED, stroke_width=4
        )
        self.play(Create(cancel_10), Create(cancel_minus10))
        self.wait(2)

        # Write = then x after cancel
        result_eq = MathTex(r"=", font_size=48)
        result_eq.move_to([eq1[3].get_x(), result_neg5.get_y(), 0])

        result_x = MathTex(r"x", font_size=48)
        result_x.move_to([eq1[0].get_x(), result_neg5.get_y(), 0])

        self.play(Write(result_eq))
        self.wait(0.5)
        self.play(Write(result_x))
        self.wait(1)

        # Step 4: Slide entire equation group to the LEFT
        eq_group = VGroup(
            eq1, minus10_left, minus10_right,
            uline_left,
            cancel_10, cancel_minus10,
            result_neg5, result_eq, result_x
        )
        self.play(eq_group.animate.shift(LEFT * 3.2), run_time=1.2)
        self.wait(0.5)

        # Step 5: Build coordinate plane on the RIGHT (like the image)
        plane = NumberPlane(
            x_range=[-8, 8, 1],
            y_range=[-6, 6, 1],
            x_length=6.5,
            y_length=5.5,
            background_line_style={
                "stroke_color": GREY,
                "stroke_width": 0.5,
                "stroke_opacity": 0.5,
            },
        )
        plane.shift(RIGHT * 3.2)
        plane.add_coordinates(
            [-8, -6, -4, -2, 2, 4, 6, 8],
            [-6, -4, -2, 2, 4, 6],
        )

        # Nudge negative x-axis labels slightly to the right
        origin_x = plane.get_origin()[0]
        for num in plane.get_x_axis().numbers:
            if num.get_center()[0] < origin_x:
                num.shift(LEFT * 0.25)

        x_label = plane.get_x_axis_label(MathTex("x", font_size=28))
        y_label = plane.get_y_axis_label(MathTex("y", font_size=28))

        self.play(Create(plane), Write(x_label), Write(y_label))
        self.wait(0.5)

        # Step 6: Draw vertical line x = -5 on the plane (red, like the image)
        vert_line = Line(
            start=plane.c2p(-5, -6),
            end=plane.c2p(-5, 6),
            color=RED,
            stroke_width=3,
        )
        line_label = MathTex(r"x = -5", font_size=26, color=RED)
        line_label.next_to(plane.c2p(-5, 6), UR, buff=0.1)

        # Dot at the x-axis crossing
        dot = Dot(plane.c2p(-5, 0), color=YELLOW, radius=0.1)

        self.play(Create(vert_line))
        self.play(
            FadeIn(dot, scale=2),
            Flash(dot, color=YELLOW, flash_radius=0.3, num_lines=10, line_length=0.12),
        )
        self.play(Write(line_label))
        self.wait(5)  # Time to read: "x = -5 on the number line" + buffer
