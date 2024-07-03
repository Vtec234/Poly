/-
Copyright (c) 2024 Emily Riehl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Emily Riehl
-/

-- import Mathlib.CategoryTheory.Adjunction.Mates
import Mathlib.CategoryTheory.Adjunction.Over
import Mathlib.CategoryTheory.Category.Basic
import Mathlib.CategoryTheory.Functor.Basic
import Mathlib.CategoryTheory.Functor.Category
import Mathlib.CategoryTheory.Whiskering

import Poly.TempMates -- Contains an open mathlib PR redoing the mates file

/-!
# Some basic equalities and isomorphisms
-/

namespace CategoryTheory
universe v₁ v₂ v₃ u₁ u₂ u₃ v u

open Category Functor Adjunction Limits NatTrans Over

section NaturalityOfWhiskering

variable {A : Type u₁} {B : Type u₂} {C : Type u₃}
variable [Category.{v₁} A] [Category.{v₂} B][Category.{v₃} C]
variable {F G : A ⥤ B}{H K : B ⥤ C}

-- Naturality of β implies naturality of whiskering; this is not used.
@[simp]
theorem WhiskeringNaturality
    (α : F ⟶ G) (β : H ⟶ K) :
    (whiskerRight α H) ≫ (whiskerLeft G β) = (whiskerLeft F β) ≫ (whiskerRight α K) := by ext; unfold whiskerLeft; simp

end NaturalityOfWhiskering

section

variable {C : Type u} [Category.{v} C]

@[simp]
lemma pullback.map_id {W X S : C} (f : W ⟶ S) (g : X ⟶ S) [HasPullback f g] (h) (h') :
    pullback.map f g f g (𝟙 W) (𝟙 X) (𝟙 S) h h' = 𝟙 (pullback f g) := by
  unfold pullback.map
  ext <;> simp

end

noncomputable section

namespace Over
variable {C : Type u} [Category.{v} C]

@[simp]
theorem eqToHom_left {X : C} {x y : Over X} (e : x = y) : (eqToHom e).left = eqToHom (e ▸ rfl) := by
  subst e; rfl

theorem mapForget_eq {X Y : C}(f : X ⟶ Y) :
    map f ⋙ forget Y = forget X := by
  fapply Functor.ext
  · dsimp [Over, Over.map]; intro x; exact rfl
  · intros x y u; simp

/-- For use elsewhere.-/
def mapForgetIso {X Y : C}(f : X ⟶ Y) :
    map f ⋙ forget Y ≅ forget X := eqToIso (mapForget_eq f)

/-- For use elsewhere.-/
def mapStarIso [HasBinaryProducts C] [HasPullbacks C] {X Y : C} (f : X ⟶ Y) :
    star X ≅ star Y ⋙ baseChange f :=
  conjugateIsoEquiv (forgetAdjStar X) ((mapAdjunction f).comp (forgetAdjStar Y)) (mapForgetIso f)

theorem mapComp_eq {X Y Z : C}(f : X ⟶ Y)(g : Y ⟶ Z) :
    map f ⋙ map g = map (f ≫ g) := by
  fapply Functor.ext
  · dsimp [Over, Over.map]; intro x; unfold Comma.mapRight; simp
  · intros x y u; ext; simp

def mapCompIso {X Y Z : C}(f : X ⟶ Y)(g : Y ⟶ Z) :
    Over.map f ⋙ Over.map g ≅ Over.map (f ≫ g) := eqToIso (mapComp_eq f g)

/-- The conjugate isomorphism between pullback functors. -/
def pullbackCompIso [HasPullbacks C] {X Y Z : C} (f : X ⟶ Y) (g : Y ⟶ Z) :
    baseChange (f ≫ g) ≅ baseChange g ⋙ baseChange f :=
  conjugateIsoEquiv (mapAdjunction (f ≫ g)) ((mapAdjunction f).comp (mapAdjunction g)) (mapCompIso f g)

def forgetAdjStar_unit [HasBinaryProducts C] (X : C) : 𝟭 (Over X) ⟶ (forget X ⋙ star X) where
  app f := homMk (prod.lift f.hom (𝟙 f.left))
  naturality U V f := by ext; simp

def forgetAdjStar_unit_eq [HasBinaryProducts C] (X : C) :
    (forgetAdjStar X).unit = forgetAdjStar_unit X := by
  ext
  simp [forgetAdjStar, forgetAdjStar_unit, Adjunction.comp, Equivalence.symm]

def forgetAdjStar_homEquiv [HasBinaryProducts C] (X : C) (U : Over X) (A : C)
    (f : U.left ⟶ A) :
    (forgetAdjStar X).homEquiv U A f =
      homMk (V := (star X).obj A) (prod.lift U.hom f) := by
  rw [homEquiv_unit, forgetAdjStar_unit_eq, forgetAdjStar_unit]
  ext
  simp

def forgetAdjStar_counit [HasBinaryProducts C] (X : C) : (star X ⋙ forget X) ⟶ 𝟭 C where
  app A := prod.snd
  naturality := by simp

def forgetAdjStar_counit_eq [HasBinaryProducts C] (X : C) :
    (forgetAdjStar X).counit = forgetAdjStar_counit X := by
  ext
  simp [forgetAdjStar, forgetAdjStar_counit, prodComonad,
    Adjunction.comp, Comonad.ε, Equivalence.symm]

def forgetAdjStar_homEquiv_symm [HasBinaryProducts C] (X : C) (U : Over X) (A : C)
    (f : U ⟶ (star X).obj A) :
    ((forgetAdjStar X).homEquiv U A).symm f = f.left ≫ prod.snd := by
  rw [homEquiv_counit, forgetAdjStar_counit_eq, forgetAdjStar_counit]
  simp

end Over

variable {C : Type*} [Category C] [HasPullbacks C]

-- Proof by Markus Himmel (with commentary by Dagur Asgeirsson)
@[simps]
def toOverTerminal' (T : C) (h : IsTerminal T) : C ⥤ Over T where
  obj X := Over.mk (h.from _)
  map f := Over.homMk f

def toOverTerminal [HasTerminal C] : C ⥤ Over (⊤_ C) :=
  toOverTerminal' (⊤_ C) terminalIsTerminal

def equivOverTerminal' (T : C) (h : IsTerminal T) : C ≌ Over T :=
  CategoryTheory.Equivalence.mk (toOverTerminal' T h) (Over.forget _)
    (NatIso.ofComponents (fun X => Iso.refl _))
    (NatIso.ofComponents (fun X => Over.isoMk (Iso.refl _) (by simpa using h.hom_ext _ _)))

def equivOverTerminal [HasTerminal C] : C ≌ Over (⊤_ C) :=
  equivOverTerminal' (⊤_ C) terminalIsTerminal

def isoOverTerminal [HasTerminal C] : Cat.of (ULift C) ≅ Cat.of (Over (⊤_ C)) where
  hom := {
    obj  := fun ⟨X⟩ => by
      exact Over.mk (terminalIsTerminal.from X)
    map := @fun ⟨X⟩ ⟨Y⟩ f => by
      exact Over.homMk f
  }
  inv := {
    obj := fun X => sorry
    map := sorry
  }
  hom_inv_id := sorry
  inv_hom_id := sorry

def toOverTerminalStarIso [HasTerminal C] [HasBinaryProducts C] : Over.star (⊤_ C) ≅ toOverTerminal := by
  have := Iso.refl (Over.forget (⊤_ C))
  sorry -- I can't seem to infer that the inverse equivalence used above is an equivalence.
  -- have : (Over.forget (⊤_ C)).IsEquivalence := by infer_instance
  -- have := (Over.forget (⊤_ C)).asEquivalence.toAdjunction
  -- have := conjugateIsoEquiv (Over.forgetAdjStar (⊤_ C)) _ this

def toOverTerminalStarTriangleIso [HasTerminal C] [HasBinaryProducts C] (X : C) : Over.star X ≅ toOverTerminal ⋙ baseChange (terminal.from X) :=
  mapStarIso (terminal.from X) ≪≫ isoWhiskerRight (toOverTerminalStarIso (C := C)) (baseChange (terminal.from X))
