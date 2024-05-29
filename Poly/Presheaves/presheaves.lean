
/-
The plan for this file is to show that the category of presheaves on a (small) cat C is LCC, as follows:
(1) define the category of presheaves on a (small) cat C and show it is a CCC,
  [* apparently this has already been done *]
(2) the slice category over any presheaf is presheaves on its category of elements,
  [* the category of elements is already done, but not the equivalence *]
(3) infer that every slice of presheaves is a CCC,
(4) use the results from the LCCC development to infer that presheaves is LCC.
-/

import Mathlib.CategoryTheory.Category.Basic
import Mathlib.CategoryTheory.Closed.Monoidal
import Mathlib.CategoryTheory.Closed.Cartesian
import Mathlib.CategoryTheory.Adjunction.Mates
import Mathlib.CategoryTheory.Limits.Constructions.Over.Basic
import Mathlib.CategoryTheory.Adjunction.Over
import Mathlib.CategoryTheory.Opposites
import Mathlib.CategoryTheory.Yoneda
import Mathlib.CategoryTheory.Closed.Types
import Mathlib.CategoryTheory.Elements
--import Mathlib.CategoryTheory.Comma.StructuredArrow

/-!
# Presheaves are a CCC
The category of presheaves on a small category is cartesian closed
-/

noncomputable section

open CategoryTheory Functor Adjunction Over Opposite

universe w v u

variable {C : Type u} [Category.{u} C]

#check CartesianClosed (Cᵒᵖ ⥤ Type u)

/- Question: how can we define the notation Psh(C) in place of (Cᵒᵖ ⥤ Type u) ?
-/


/-!
# The dual category of elements
The category of elements of a *contravariant* functor P : Cᵒᵖ ⥤ Type is the opposite of the category of elements of the opposite functor Pᵒᵖ : C ⥤ Typeᵒᵖ.

Given a functor `P : Cᵒᵖ ⥤ Type`, an object of
`P.OpElements` is a pair `(X : C, x : P.obj X)`.
A morphism `(X, x) ⟶ (Y, y)` is a morphism `f : X ⟶ Y` in `C`, so `P.map f` takes `y` to `x`.

P.OpElements is equivalent to the comma category Yoneda/P.
-/

noncomputable section Elements

variable {C : Type u} [Category.{v} C]

/--
The type of objects for the category of elements of a functor `P : Cᵒᵖ ⥤ Type` is a pair `(X : C, x : P.obj X)`.
-/

def Functor.OpElements (P : Cᵒᵖ ⥤ Type w) :=
(Functor.Elements P)ᵒᵖ --  Σ X : Cᵒᵖ, P.obj X

lemma Functor.OpElements.ext {P : Cᵒᵖ ⥤ Type w} (x y : P.Elements) (h₁ : x.fst = y.fst)
  (h₂ : P.map (eqToHom h₁)
    x.snd = y.snd) : x = y := by
    cases x
    cases y
    cases h₁
    simp only [eqToHom_refl, FunctorToTypes.map_id_apply] at h₂
    simp [h₂]

/--
The category structure on `P.OpElements`, for `P : Cᵒᵖ ⥤ Type`.
A morphism `(X, x) ⟶ (Y, y)` is a morphism `f : X ⟶ Y` in `C`, so `F.map f` takes `y` to `x`.
 -/

 instance categoryOfOpElements (P : Cᵒᵖ ⥤ Type w) : Category.{v} (OpElements P) where
  Hom p q := { f : (unop p).1 ⟶ (unop q).1 // (unop q).2 = P.map f (unop p).2 }
  id p := ⟨𝟙 (unop p).1, by aesop_cat⟩
  comp {X Y Z} f g := ⟨f.val ≫ g.val, by simp [f.2, g.2]⟩

namespace CategoryTheory
namespace CategoryOfElements

/-- The equivalence `P.OpElements ≅ (yoneda, P)` given by the Yoneda lemma. -/

/- there's still a mismatch here, since (Functor.Elements P)ᵒᵖ should be the same as (Functor.OpElements P), but apparently isn't definitionally equal-/

def costructuredArrowYonedaEquivalenceOp (P : Cᵒᵖ ⥤ Type v) :
    (Functor.Elements P)ᵒᵖ ≌ CostructuredArrow yoneda P :=
  Equivalence.mk (toCostructuredArrow P) (fromCostructuredArrow P).rightOp
    (NatIso.op (eqToIso (from_toCostructuredArrow_eq P))) (eqToIso <| to_fromCostructuredArrow_eq P)

/-
next: show that Psh(C)/P = (Yoneda, P) = Psh(OpElements P)
-/


/- then we'll use the following to transfer CCC across the equivalence

variable {D : Type u₂} [Category.{v} D]

copied from: mathlib4/Mathlib/CategoryTheory/Closed
/Cartesian.lean

universe v u u₂

noncomputable section

namespace CategoryTheory

open CategoryTheory CategoryTheory.Category CategoryTheory.Limits

attribute [local instance] monoidalOfHasFiniteProducts

...

section Functor

variable [HasFiniteProducts D]

/-- Transport the property of being cartesian closed across an equivalence of categories.

Note we didn't require any coherence between the choice of finite products here, since we transport
along the `prodComparison` isomorphism.
-/
def cartesianClosedOfEquiv (e : C ≌ D) [CartesianClosed C] : CartesianClosed D :=
  MonoidalClosed.ofEquiv (e.inverse.toMonoidalFunctorOfHasFiniteProducts) e.symm.toAdjunction
#align category_theory.cartesian_closed_of_equiv CategoryTheory.cartesianClosedOfEquiv

end Functor

attribute [nolint simpNF] CategoryTheory.CartesianClosed.homEquiv_apply_eq
  CategoryTheory.CartesianClosed.homEquiv_symm_apply_eq
end CategoryTheory
-/
