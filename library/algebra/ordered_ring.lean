/-
Copyright (c) 2014 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

Module: algebra.ordered_ring
Authors: Jeremy Avigad

Here an "ordered_ring" is partially ordered ring, which is ordered with respect to both a weak
order and an associated strict order. Our numeric structures (int, rat, and real) will be instances
of "linear_ordered_comm_ring". This development is modeled after Isabelle's library.
-/

import algebra.ordered_group algebra.ring
open eq eq.ops

namespace algebra

variable {A : Type}

structure ordered_semiring [class] (A : Type)
  extends has_mul A, has_zero A, has_lt A, -- TODO: remove hack for improving performance
    semiring A, ordered_cancel_comm_monoid A :=
(mul_le_mul_of_nonneg_left: ∀a b c, le a b → le zero c → le (mul c a) (mul c b))
(mul_le_mul_of_nonneg_right: ∀a b c, le a b → le zero c → le (mul a c) (mul b c))
(mul_lt_mul_of_pos_left: ∀a b c, lt a b → lt zero c → lt (mul c a) (mul c b))
(mul_lt_mul_of_pos_right: ∀a b c, lt a b → lt zero c → lt (mul a c) (mul b c))

section
  variable [s : ordered_semiring A]
  variables (a b c d e : A)
  include s

  theorem mul_le_mul_of_nonneg_left {a b c : A} (Hab : a ≤ b) (Hc : 0 ≤ c) :
    c * a ≤ c * b := !ordered_semiring.mul_le_mul_of_nonneg_left Hab Hc

  theorem mul_le_mul_of_nonneg_right {a b c : A} (Hab : a ≤ b) (Hc : 0 ≤ c) :
    a * c ≤ b * c := !ordered_semiring.mul_le_mul_of_nonneg_right Hab Hc

  -- TODO: there are four variations, depending on which variables we assume to be nonneg
  theorem mul_le_mul {a b c d : A} (Hac : a ≤ c) (Hbd : b ≤ d) (nn_b : 0 ≤ b) (nn_c : 0 ≤ c) :
    a * b ≤ c * d :=
  calc
    a * b ≤ c * b : mul_le_mul_of_nonneg_right Hac nn_b
      ... ≤ c * d : mul_le_mul_of_nonneg_left Hbd nn_c

  theorem mul_nonneg {a b : A} (Ha : a ≥ 0) (Hb : b ≥ 0) : a * b ≥ 0 :=
  have H : 0 * b ≤ a * b, from mul_le_mul_of_nonneg_right Ha Hb,
  !zero_mul ▸ H

  theorem mul_nonpos_of_nonneg_of_nonpos {a b : A} (Ha : a ≥ 0) (Hb : b ≤ 0) : a * b ≤ 0 :=
  have H : a * b ≤ a * 0, from mul_le_mul_of_nonneg_left Hb Ha,
  !mul_zero ▸ H

  theorem mul_nonpos_of_nonpos_of_nonneg {a b : A} (Ha : a ≤ 0) (Hb : b ≥ 0) : a * b ≤ 0 :=
  have H : a * b ≤ 0 * b, from mul_le_mul_of_nonneg_right Ha Hb,
  !zero_mul ▸ H

  theorem mul_lt_mul_of_pos_left {a b c : A} (Hab : a < b) (Hc : 0 < c) :
    c * a < c * b := !ordered_semiring.mul_lt_mul_of_pos_left Hab Hc

  theorem mul_lt_mul_of_pos_right {a b c : A} (Hab : a < b) (Hc : 0 < c) :
    a * c < b * c := !ordered_semiring.mul_lt_mul_of_pos_right Hab Hc

  -- TODO: once again, there are variations
  theorem mul_lt_mul {a b c d : A} (Hac : a < c) (Hbd : b ≤ d) (pos_b : 0 < b) (nn_c : 0 ≤ c) :
    a * b < c * d :=
  calc
    a * b < c * b : mul_lt_mul_of_pos_right Hac pos_b
      ... ≤ c * d : mul_le_mul_of_nonneg_left Hbd nn_c

  theorem mul_pos {a b : A} (Ha : a > 0) (Hb : b > 0) : a * b > 0 :=
  have H : 0 * b < a * b, from mul_lt_mul_of_pos_right Ha Hb,
  !zero_mul ▸ H

  theorem mul_neg_of_pos_of_neg {a b : A} (Ha : a > 0) (Hb : b < 0) : a * b < 0 :=
  have H : a * b < a * 0, from mul_lt_mul_of_pos_left Hb Ha,
  !mul_zero ▸ H

  theorem mul_neg_of_neg_of_pos {a b : A} (Ha : a < 0) (Hb : b > 0) : a * b < 0 :=
  have H : a * b < 0 * b, from mul_lt_mul_of_pos_right Ha Hb,
  !zero_mul ▸ H
end

structure linear_ordered_semiring [class] (A : Type)
    extends ordered_semiring A, linear_strong_order_pair A

section
  variable [s : linear_ordered_semiring A]
  variables {a b c : A}
  include s

  theorem lt_of_mul_lt_mul_left (H : c * a < c * b) (Hc : c ≥ 0) : a < b :=
  lt_of_not_le
    (assume H1 : b ≤ a,
      have H2 : c * b ≤ c * a, from mul_le_mul_of_nonneg_left H1 Hc,
      not_lt_of_le H2 H)

  theorem lt_of_mul_lt_mul_right (H : a * c < b * c) (Hc : c ≥ 0) : a < b :=
  lt_of_not_le
    (assume H1 : b ≤ a,
      have H2 : b * c ≤ a * c, from mul_le_mul_of_nonneg_right H1 Hc,
      not_lt_of_le H2 H)

  theorem le_of_mul_le_mul_left (H : c * a ≤ c * b) (Hc : c > 0) : a ≤ b :=
  le_of_not_lt
    (assume H1 : b < a,
      have H2 : c * b < c * a, from mul_lt_mul_of_pos_left H1 Hc,
      not_le_of_lt H2 H)

  theorem le_of_mul_le_mul_right (H : a * c ≤ b * c) (Hc : c > 0) : a ≤ b :=
  le_of_not_lt
    (assume H1 : b < a,
      have H2 : b * c < a * c, from mul_lt_mul_of_pos_right H1 Hc,
      not_le_of_lt H2 H)

  theorem pos_of_mul_pos_left (H : 0 < a * b) (H1 : 0 ≤ a) : 0 < b :=
  lt_of_not_le
    (assume H2 : b ≤ 0,
      have H3 : a * b ≤ 0, from mul_nonpos_of_nonneg_of_nonpos H1 H2,
      not_lt_of_le H3 H)

  theorem pos_of_mul_pos_right (H : 0 < a * b) (H1 : 0 ≤ b) : 0 < a :=
  lt_of_not_le
    (assume H2 : a ≤ 0,
      have H3 : a * b ≤ 0, from mul_nonpos_of_nonpos_of_nonneg H2 H1,
      not_lt_of_le H3 H)
end

structure ordered_ring [class] (A : Type) extends ring A, ordered_comm_group A :=
(mul_nonneg : ∀a b, le zero a → le zero b → le zero (mul a b))
(mul_pos : ∀a b, lt zero a → lt zero b → lt zero (mul a b))

theorem ordered_ring.mul_le_mul_of_nonneg_left [s : ordered_ring A] {a b c : A}
        (Hab : a ≤ b) (Hc : 0 ≤ c) : c * a ≤ c * b :=
have H1 : 0 ≤ b - a, from iff.elim_right !sub_nonneg_iff_le Hab,
have H2 : 0 ≤ c * (b - a), from ordered_ring.mul_nonneg _ _ Hc H1,
iff.mp !sub_nonneg_iff_le (!mul_sub_left_distrib ▸ H2)

theorem ordered_ring.mul_le_mul_of_nonneg_right [s : ordered_ring A] {a b c : A}
        (Hab : a ≤ b) (Hc : 0 ≤ c) : a * c ≤ b * c  :=
have H1 : 0 ≤ b - a, from iff.elim_right !sub_nonneg_iff_le Hab,
have H2 : 0 ≤ (b - a) * c, from ordered_ring.mul_nonneg _ _ H1 Hc,
iff.mp !sub_nonneg_iff_le (!mul_sub_right_distrib ▸ H2)

theorem ordered_ring.mul_lt_mul_of_pos_left [s : ordered_ring A] {a b c : A}
       (Hab : a < b) (Hc : 0 < c) : c * a < c * b :=
have H1 : 0 < b - a, from iff.elim_right !sub_pos_iff_lt Hab,
have H2 : 0 < c * (b - a), from ordered_ring.mul_pos _ _ Hc H1,
iff.mp !sub_pos_iff_lt (!mul_sub_left_distrib ▸ H2)

theorem ordered_ring.mul_lt_mul_of_pos_right [s : ordered_ring A] {a b c : A}
       (Hab : a < b) (Hc : 0 < c) : a * c < b * c :=
have H1 : 0 < b - a, from iff.elim_right !sub_pos_iff_lt Hab,
have H2 : 0 < (b - a) * c, from ordered_ring.mul_pos _ _ H1 Hc,
iff.mp !sub_pos_iff_lt (!mul_sub_right_distrib ▸ H2)

definition ordered_ring.to_ordered_semiring [instance] [coercion] [s : ordered_ring A] :
  ordered_semiring A :=
⦃ ordered_semiring, s,
  mul_zero                   := mul_zero,
  zero_mul                   := zero_mul,
  add_left_cancel            := @add.left_cancel A s,
  add_right_cancel           := @add.right_cancel A s,
  le_of_add_le_add_left      := @le_of_add_le_add_left A s,
  mul_le_mul_of_nonneg_left  := @ordered_ring.mul_le_mul_of_nonneg_left A s,
  mul_le_mul_of_nonneg_right := @ordered_ring.mul_le_mul_of_nonneg_right A s,
  mul_lt_mul_of_pos_left     := @ordered_ring.mul_lt_mul_of_pos_left A s,
  mul_lt_mul_of_pos_right    := @ordered_ring.mul_lt_mul_of_pos_right A s ⦄

section
  variable [s : ordered_ring A]
  variables {a b c : A}
  include s

  theorem mul_le_mul_of_nonpos_left (H : b ≤ a) (Hc : c ≤ 0) : c * a ≤ c * b :=
  have Hc' : -c ≥ 0, from iff.mp' !neg_nonneg_iff_nonpos Hc,
  have H1 : -c * b ≤ -c * a, from mul_le_mul_of_nonneg_left H Hc',
  have H2 : -(c * b) ≤ -(c * a), from !neg_mul_eq_neg_mul⁻¹ ▸ !neg_mul_eq_neg_mul⁻¹ ▸ H1,
  iff.mp !neg_le_neg_iff_le H2

  theorem mul_le_mul_of_nonpos_right (H : b ≤ a) (Hc : c ≤ 0) : a * c ≤ b * c :=
  have Hc' : -c ≥ 0, from iff.mp' !neg_nonneg_iff_nonpos Hc,
  have H1 : b * -c ≤ a * -c, from mul_le_mul_of_nonneg_right H Hc',
  have H2 : -(b * c) ≤ -(a * c), from !neg_mul_eq_mul_neg⁻¹ ▸ !neg_mul_eq_mul_neg⁻¹ ▸ H1,
  iff.mp !neg_le_neg_iff_le H2

  theorem mul_nonneg_of_nonpos_of_nonpos (Ha : a ≤ 0) (Hb : b ≤ 0) : 0 ≤ a * b :=
  !zero_mul ▸ mul_le_mul_of_nonpos_right Ha Hb

  theorem mul_lt_mul_of_neg_left (H : b < a) (Hc : c < 0) : c * a < c * b :=
  have Hc' : -c > 0, from iff.mp' !neg_pos_iff_neg Hc,
  have H1 : -c * b < -c * a, from mul_lt_mul_of_pos_left H Hc',
  have H2 : -(c * b) < -(c * a), from !neg_mul_eq_neg_mul⁻¹ ▸ !neg_mul_eq_neg_mul⁻¹ ▸ H1,
  iff.mp !neg_lt_neg_iff_lt H2

  theorem mul_lt_mul_of_neg_right (H : b < a) (Hc : c < 0) : a * c < b * c :=
  have Hc' : -c > 0, from iff.mp' !neg_pos_iff_neg Hc,
  have H1 : b * -c < a * -c, from mul_lt_mul_of_pos_right H Hc',
  have H2 : -(b * c) < -(a * c), from !neg_mul_eq_mul_neg⁻¹ ▸ !neg_mul_eq_mul_neg⁻¹ ▸ H1,
  iff.mp !neg_lt_neg_iff_lt H2

  theorem mul_pos_of_neg_of_neg (Ha : a < 0) (Hb : b < 0) : 0 < a * b :=
  !zero_mul ▸ mul_lt_mul_of_neg_right Ha Hb
end

-- TODO: we can eliminate mul_pos_of_pos, but now it is not worth the effort to redeclare the
-- class instance
structure linear_ordered_ring [class] (A : Type) extends ordered_ring A, linear_strong_order_pair A

-- print fields linear_ordered_semiring

definition linear_ordered_ring.to_linear_ordered_semiring [instance] [coercion]
    [s : linear_ordered_ring A] :
  linear_ordered_semiring A :=
⦃ linear_ordered_semiring, s,
  mul_zero                   := mul_zero,
  zero_mul                   := zero_mul,
  add_left_cancel            := @add.left_cancel A s,
  add_right_cancel           := @add.right_cancel A s,
  le_of_add_le_add_left      := @le_of_add_le_add_left A s,
  mul_le_mul_of_nonneg_left  := @mul_le_mul_of_nonneg_left A s,
  mul_le_mul_of_nonneg_right := @mul_le_mul_of_nonneg_right A s,
  mul_lt_mul_of_pos_left     := @mul_lt_mul_of_pos_left A s,
  mul_lt_mul_of_pos_right    := @mul_lt_mul_of_pos_right A s,
  le_total                   := linear_ordered_ring.le_total ⦄

structure linear_ordered_comm_ring [class] (A : Type) extends linear_ordered_ring A, comm_monoid A

theorem linear_ordered_comm_ring.eq_zero_or_eq_zero_of_mul_eq_zero [s : linear_ordered_comm_ring A]
        {a b : A} (H : a * b = 0) : a = 0 ∨ b = 0 :=
lt.by_cases
  (assume Ha : 0 < a,
    lt.by_cases
      (assume Hb : 0 < b, absurd (H ▸ show 0 < a * b, from mul_pos Ha Hb) (lt.irrefl 0))
      (assume Hb : 0 = b, or.inr (Hb⁻¹))
      (assume Hb : 0 > b,
        absurd (H ▸ show 0 > a * b, from mul_neg_of_pos_of_neg Ha Hb) (lt.irrefl 0)))
  (assume Ha : 0 = a, or.inl (Ha⁻¹))
  (assume Ha : 0 > a,
    lt.by_cases
      (assume Hb : 0 < b,
        absurd (H ▸ show 0 > a * b, from mul_neg_of_neg_of_pos Ha Hb) (lt.irrefl 0))
      (assume Hb : 0 = b, or.inr (Hb⁻¹))
      (assume Hb : 0 > b,
        absurd (H ▸ show 0 < a * b, from mul_pos_of_neg_of_neg Ha Hb) (lt.irrefl 0)))

-- Linearity implies no zero divisors. Doesn't need commutativity.
definition linear_ordered_comm_ring.to_integral_domain [instance] [coercion]
    [s: linear_ordered_comm_ring A] : integral_domain A :=
⦃ integral_domain, s,
  eq_zero_or_eq_zero_of_mul_eq_zero :=
     @linear_ordered_comm_ring.eq_zero_or_eq_zero_of_mul_eq_zero A s ⦄

section
  variable [s : linear_ordered_ring A]
  variables (a b c : A)
  include s

  theorem mul_self_nonneg : a * a ≥ 0 :=
  or.elim (le.total 0 a)
    (assume H : a ≥ 0, mul_nonneg H H)
    (assume H : a ≤ 0, mul_nonneg_of_nonpos_of_nonpos H H)

  theorem zero_le_one : 0 ≤ 1 := one_mul 1 ▸ mul_self_nonneg 1
  theorem zero_lt_one : 0 < 1 := lt_of_le_of_ne zero_le_one zero_ne_one

  theorem pos_and_pos_or_neg_and_neg_of_mul_pos {a b : A} (Hab : a * b > 0) :
    (a > 0 ∧ b > 0) ∨ (a < 0 ∧ b < 0) :=
  lt.by_cases
    (assume Ha : 0 < a,
      lt.by_cases
        (assume Hb : 0 < b, or.inl (and.intro Ha Hb))
        (assume Hb : 0 = b,
          absurd (!mul_zero ▸ Hb⁻¹ ▸ Hab) (lt.irrefl 0))
        (assume Hb : b < 0,
          absurd Hab (lt.asymm (mul_neg_of_pos_of_neg Ha Hb))))
    (assume Ha : 0 = a,
      absurd (!zero_mul ▸ Ha⁻¹ ▸ Hab) (lt.irrefl 0))
    (assume Ha : a < 0,
      lt.by_cases
        (assume Hb : 0 < b,
          absurd Hab (lt.asymm (mul_neg_of_neg_of_pos Ha Hb)))
        (assume Hb : 0 = b,
          absurd (!mul_zero ▸ Hb⁻¹ ▸ Hab) (lt.irrefl 0))
        (assume Hb : b < 0, or.inr (and.intro Ha Hb)))
end

/- TODO: Isabelle's library has all kinds of cancelation rules for the simplifier.
   Search on mult_le_cancel_right1 in Rings.thy. -/

structure decidable_linear_ordered_comm_ring [class] (A : Type) extends linear_ordered_comm_ring A,
    decidable_linear_ordered_comm_group A

section
  variable [s : decidable_linear_ordered_comm_ring A]
  variables {a b c : A}
  include s

  definition sign (a : A) : A := lt.cases a 0 (-1) 0 1

  theorem sign_of_neg (H : a < 0) : sign a = -1 := lt.cases_of_lt H

  theorem sign_zero : sign 0 = 0 := lt.cases_of_eq rfl

  theorem sign_of_pos (H : a > 0) : sign a = 1 := lt.cases_of_gt H

  theorem sign_one : sign 1 = 1 := sign_of_pos zero_lt_one

  theorem sign_neg_one : sign (-1) = -1 := sign_of_neg (neg_neg_of_pos zero_lt_one)

  theorem sign_sign (a : A) : sign (sign a) = sign a :=
  lt.by_cases
    (assume H : a > 0,
      calc
        sign (sign a) = sign 1 : {sign_of_pos H}
                  ... = 1      : sign_one
                  ... = sign a : sign_of_pos H)
    (assume H : 0 = a,
      calc
        sign (sign a) = sign (sign 0) : H
                  ... = sign 0        : sign_zero
                  ... = sign a        : H)
    (assume H : a < 0,
      calc
        sign (sign a) = sign (-1)     : {sign_of_neg H}
                  ... = -1            : sign_neg_one
                  ... = sign a        : sign_of_neg H)

  theorem pos_of_sign_eq_one (H : sign a = 1) : a > 0 :=
  lt.by_cases
    (assume H1 : 0 < a, H1)
    (assume H1 : 0 = a, absurd (sign_zero⁻¹ ⬝ (H1⁻¹ ▸ H)) zero_ne_one)
    (assume H1 : 0 > a,
      have H2 : -1 = 1, from (sign_of_neg H1)⁻¹ ⬝ H,
      absurd ((eq_zero_of_neg_eq H2)⁻¹) zero_ne_one)

  theorem eq_zero_of_sign_eq_zero (H : sign a = 0) : a = 0 :=
  lt.by_cases
    (assume H1 : 0 < a, absurd (H⁻¹ ⬝ sign_of_pos H1) zero_ne_one)
    (assume H1 : 0 = a, H1⁻¹)
    (assume H1 : 0 > a,
      have H2 : 0 = -1, from H⁻¹ ⬝ sign_of_neg H1,
      have H3 : 1 = 0, from eq_neg_of_eq_neg H2 ⬝ neg_zero,
      absurd (H3⁻¹) zero_ne_one)

  theorem neg_of_sign_eq_neg_one (H : sign a = -1) : a < 0 :=
  lt.by_cases
    (assume H1 : 0 < a,
      have H2 : -1 = 1, from H⁻¹ ⬝ (sign_of_pos H1),
      absurd ((eq_zero_of_neg_eq H2)⁻¹) zero_ne_one)
    (assume H1 : 0 = a,
      have H2 : 0 = -1, from (H1 ▸ sign_zero)⁻¹ ⬝ H,
      have H3 : 1 = 0, from eq_neg_of_eq_neg H2 ⬝ neg_zero,
      absurd (H3⁻¹) zero_ne_one)
    (assume H1 : 0 > a, H1)

  theorem sign_neg (a : A) : sign (-a) = -(sign a) :=
  lt.by_cases
    (assume H1 : 0 < a,
      calc
        sign (-a) = -1        : sign_of_neg (neg_neg_of_pos H1)
              ... = -(sign a) : {(sign_of_pos H1)⁻¹})
    (assume H1 : 0 = a,
      calc
        sign (-a) = sign (-0) : H1
              ... = sign 0    : {neg_zero} -- TODO: why do we need {}?
              ... = 0         : sign_zero
              ... = -0        : neg_zero
              ... = -(sign 0) : sign_zero
              ... = -(sign a) : H1)
    (assume H1 : 0 > a,
      calc
        sign (-a) = 1         : sign_of_pos (neg_pos_of_neg H1)
              ... = -(-1)     : neg_neg
              ... = -(sign a) : {(sign_of_neg H1)⁻¹})

  -- hopefully, will be quick with the simplifier
  theorem sign_mul (a b : A) : sign (a * b) = sign a * sign b := sorry

  theorem abs_eq_sign_mul (a : A) : |a| = sign a * a :=
  lt.by_cases
    (assume H1 : 0 < a,
      calc
        |a| = a          : abs_of_pos H1
        ... = 1 * a      : one_mul
        ... = sign a * a : {(sign_of_pos H1)⁻¹})
    (assume H1 : 0 = a,
      calc
        |a| = |0|        : H1
        ... = 0          : abs_zero
        ... = 0 * a      : zero_mul
        ... = sign 0 * a : sign_zero
        ... = sign a * a : H1)
    (assume H1 : a < 0,
      calc
        |a| = -a : abs_of_neg H1
          ... = -1 * a : neg_eq_neg_one_mul
          ... = sign a * a : {(sign_of_neg H1)⁻¹})

  theorem eq_sign_mul_abs (a : A) : a = sign a * |a| :=
  lt.by_cases
    (assume H1 : 0 < a,
      calc
        a = |a|              : abs_of_pos H1
          ... = 1 * |a|      : one_mul
          ... = sign a * |a| : {(sign_of_pos H1)⁻¹})
    (assume H1 : 0 = a,
      calc
        a = 0        : H1
          ... = 0 * |a|      : zero_mul
          ... = sign 0 * |a| : sign_zero
          ... = sign a * |a| : H1)
    (assume H1 : a < 0,
      calc
        a = -(-a)            : neg_neg
          ... = -|a|         : {(abs_of_neg H1)⁻¹}
          ... = -1 * |a|     : neg_eq_neg_one_mul
          ... = sign a * |a| : {(sign_of_neg H1)⁻¹})

  theorem abs_dvd_iff_dvd (a b : A) : |a| | b ↔ a | b :=
  abs.by_cases !iff.refl !neg_dvd_iff_dvd

  theorem dvd_abs_iff (a b : A) : a | |b| ↔ a | b :=
  abs.by_cases !iff.refl !dvd_neg_iff_dvd

  theorem abs_mul (a b : A) : |a * b| = |a| * |b| :=
  or.elim (le.total 0 a)
    (assume H1 : 0 ≤ a,
      or.elim (le.total 0 b)
        (assume H2 : 0 ≤ b,
          calc
            |a * b| = a * b     : abs_of_nonneg (mul_nonneg H1 H2)
                ... = |a| * b   : {(abs_of_nonneg H1)⁻¹}
                ... = |a| * |b| : {(abs_of_nonneg H2)⁻¹})
        (assume H2 : b ≤ 0,
          calc
            |a * b| = -(a * b)  : abs_of_nonpos (mul_nonpos_of_nonneg_of_nonpos H1 H2)
                ... = a * -b    : neg_mul_eq_mul_neg
                ... = |a| * -b  : {(abs_of_nonneg H1)⁻¹}
                ... = |a| * |b| : {(abs_of_nonpos H2)⁻¹}))
    (assume H1 : a ≤ 0,
      or.elim (le.total 0 b)
        (assume H2 : 0 ≤ b,
          calc
            |a * b| = -(a * b)  : abs_of_nonpos (mul_nonpos_of_nonpos_of_nonneg H1 H2)
                ... = -a * b    : neg_mul_eq_neg_mul
                ... = |a| * b   : {(abs_of_nonpos H1)⁻¹}
                ... = |a| * |b| : {(abs_of_nonneg H2)⁻¹})
        (assume H2 : b ≤ 0,
          calc
            |a * b| = a * b     : abs_of_nonneg (mul_nonneg_of_nonpos_of_nonpos H1 H2)
                ... = -a * -b   : neg_mul_neg
                ... = |a| * -b  : {(abs_of_nonpos H1)⁻¹}
                ... = |a| * |b| : {(abs_of_nonpos H2)⁻¹}))

  theorem abs_mul_self (a : A) : |a| * |a| = a * a :=
  abs.by_cases rfl !neg_mul_neg
end

/- TODO: Multiplication and one, starting with mult_right_le_one_le. -/

end algebra
