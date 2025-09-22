# Responsive Design - TechPlus

## 📱 Breakpoints

### Mobile
- **Largeur** : < 768px
- **Orientation** : Portrait principalement
- **Interaction** : Tactile
- **Navigation** : Menu hamburger

### Tablet
- **Largeur** : 768px - 1024px
- **Orientation** : Portrait et paysage
- **Interaction** : Tactile et souris
- **Navigation** : Menu adaptatif

### Desktop
- **Largeur** : > 1024px
- **Orientation** : Paysage principalement
- **Interaction** : Souris et clavier
- **Navigation** : Menu horizontal complet

## 🎨 Adaptations par Device

### Mobile (< 768px)

#### Navigation
- **Menu hamburger** : Icône en haut à droite
- **Drawer** : Menu coulissant depuis la gauche
- **Bottom navigation** : Navigation principale en bas
- **Floating action button** : Bouton d'action principal

#### Calendrier
- **Vue simplifiée** : Une semaine visible
- **Swipe** : Navigation par glissement
- **Créneaux** : Liste verticale des heures
- **Sélection** : Tap pour sélectionner

#### Formulaires
- **Champs pleine largeur** : Utilisation optimale de l'espace
- **Labels au-dessus** : Économie d'espace horizontal
- **Boutons larges** : Facilite le tap
- **Validation** : Messages d'erreur clairs

#### Images
- **Tailles optimisées** : 1x, 2x, 3x pour différentes densités
- **Lazy loading** : Chargement à la demande
- **Compression** : Images légères pour mobile
- **Format WebP** : Meilleure compression

### Tablet (768px - 1024px)

#### Navigation
- **Menu adaptatif** : Entre mobile et desktop
- **Sidebar** : Menu latéral possible
- **Tabs** : Navigation par onglets
- **Breadcrumbs** : Fil d'Ariane

#### Calendrier
- **Vue hybride** : Mois et semaine
- **Split view** : Calendrier + détails
- **Drag & drop** : Déplacement des réservations
- **Multi-sélection** : Sélection multiple

#### Formulaires
- **Layout en colonnes** : 2 colonnes quand possible
- **Champs groupés** : Logique de regroupement
- **Validation en temps réel** : Feedback immédiat
- **Auto-complete** : Suggestions intelligentes

### Desktop (> 1024px)

#### Navigation
- **Menu horizontal** : Navigation complète visible
- **Dropdowns** : Menus déroulants
- **Breadcrumbs** : Navigation contextuelle
- **Shortcuts** : Raccourcis clavier

#### Calendrier
- **Vue complète** : Mois entier visible
- **Multi-vues** : Mois, semaine, jour simultanément
- **Drag & drop** : Déplacement avancé
- **Raccourcis** : Navigation clavier

#### Formulaires
- **Layout multi-colonnes** : 3+ colonnes
- **Sidebar** : Informations contextuelles
- **Validation avancée** : Feedback riche
- **Auto-save** : Sauvegarde automatique

## 🎯 Composants Responsive

### Cards
```css
/* Mobile */
.card {
  width: 100%;
  margin: 8px 0;
}

/* Tablet */
@media (min-width: 768px) {
  .card {
    width: calc(50% - 16px);
    margin: 8px;
  }
}

/* Desktop */
@media (min-width: 1024px) {
  .card {
    width: calc(33.333% - 16px);
    margin: 8px;
  }
}
```

### Grid System
```css
/* Mobile First */
.grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 16px;
}

/* Tablet */
@media (min-width: 768px) {
  .grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

/* Desktop */
@media (min-width: 1024px) {
  .grid {
    grid-template-columns: repeat(3, 1fr);
  }
}
```

### Typography
```css
/* Mobile */
h1 { font-size: 24px; }
h2 { font-size: 20px; }
body { font-size: 16px; }

/* Tablet */
@media (min-width: 768px) {
  h1 { font-size: 28px; }
  h2 { font-size: 24px; }
  body { font-size: 18px; }
}

/* Desktop */
@media (min-width: 1024px) {
  h1 { font-size: 32px; }
  h2 { font-size: 28px; }
  body { font-size: 20px; }
}
```

## 🖼️ Images Responsive

### Techniques
- **srcset** : Images multiples par densité
- **sizes** : Tailles selon le viewport
- **WebP** : Format moderne avec fallback
- **Lazy loading** : Chargement différé

### Exemple
```html
<picture>
  <source 
    media="(min-width: 1024px)" 
    srcset="image-desktop.webp 1x, image-desktop-2x.webp 2x"
    type="image/webp">
  <source 
    media="(min-width: 768px)" 
    srcset="image-tablet.webp 1x, image-tablet-2x.webp 2x"
    type="image/webp">
  <source 
    srcset="image-mobile.webp 1x, image-mobile-2x.webp 2x"
    type="image/webp">
  <img 
    src="image-mobile.jpg" 
    alt="Description"
    loading="lazy">
</picture>
```

## 📐 Spacing System

### Mobile
- **Base unit** : 8px
- **Small** : 8px
- **Medium** : 16px
- **Large** : 24px
- **XLarge** : 32px

### Tablet
- **Base unit** : 12px
- **Small** : 12px
- **Medium** : 24px
- **Large** : 36px
- **XLarge** : 48px

### Desktop
- **Base unit** : 16px
- **Small** : 16px
- **Medium** : 32px
- **Large** : 48px
- **XLarge** : 64px

## 🎨 Thème Adaptatif

### Couleurs
- **Contraste** : Respect WCAG AA
- **Mode sombre** : Support automatique
- **Couleurs système** : Adaptation OS

### Animations
- **Mobile** : Animations réduites
- **Tablet** : Animations modérées
- **Desktop** : Animations complètes
- **Respect** : Préférences utilisateur

## 🔧 Outils de Test

### Emulation
- **Chrome DevTools** : Simulation devices
- **Firefox Responsive** : Mode responsive
- **Safari Web Inspector** : Simulation iOS

### Tests Réels
- **BrowserStack** : Tests cross-browser
- **Device Labs** : Tests sur vrais devices
- **User Testing** : Tests utilisateurs réels

### Métriques
- **Core Web Vitals** : Performance mobile
- **Lighthouse** : Audit complet
- **PageSpeed Insights** : Optimisation
