# Reviewed image refinements

Created with the built-in imagegen tool on 2026-11-27. These files are project
sources; `scripts/prepare_art.py` performs deterministic packing afterward. The
original candidates remain unchanged. No API key or CLI generation is required.

## `room/main_room.png`

Input/edit target: `art/replacements/room/main_room.png`.

> Use case: precise-object-edit. Asset type: finished 16:9 1280x720 logical background for a Godot cosy virtual pet room. Edit the supplied room concept, preserving its warm storybook painted style, palette, wood texture, lighting and identities of fixed furniture. Repaint cleanly at high resolution with crisp hand-drawn outlines, no upscaling blur. Remove ALL floor rugs, loose cushions, potted or hanging plants and framed pictures: these are separately purchasable game sprites and must not be baked into the room. Keep the wooden bed with cream/blush bedding, tall bookcase at far LEFT, large arched window with curtains, small tea table at far RIGHT. Reserve clear quiet wall behind HUD at top centre and top right, with NO string lights or busy objects in the top 30 percent; reserve EMPTY wooden floor across the centre and foreground for character and game controls. Move furniture visually toward left/right walls so central floor is clear behind the Baga character area x=510..770 y=220..540 in 1280x720 coordinates. The back wall/floor junction should be around y=390 so Baga's feet at y=535 stand on floor. Leave blank left wall area x=60..200 y=120..260 for an optional portrait, and empty floor x=150..300 y=360..540 for an optional plant. No characters, text, labels, interface, icons or border. Output one polished full-bleed room background, exact 16:9 composition.

Review: approved with HUD backing and tested decor placement. The generated
furniture positions differ from the requested coordinates; actual scene placement,
not prompt coordinates, is authoritative. Packed to 1280×720 without distortion.

## `baga/body_underlay.png`

Input/edit target: `art/replacements/baga/body.png`. Supporting reference:
`art/replacements/baga/preview.png`. Transparent output requested and preserved.

> Use case: precise-object-edit. Asset: hidden body underpainting for a layered Godot paper doll. Image 1 is the edit target: the original 256x320 registered body layer, with isolated hands, legs, tiny neck and shoulders and a missing torso. Image 2 is the assembled Baga visual reference, NOT the output. Reconstruct the missing occluded skin art on image 1 as ONE complete neck, small rounded torso, two short arms with mitten hands, two separated legs with white socks. A modest plain cream undershirt and shorts can cover the torso/hips, no anatomy or nudity details. Preserve the exact original positions of the visible hands and legs and the same 256:320 aspect transparent canvas. Body content only in x=58..205 y=166..294 of the 256x320 logical canvas. The upper half of canvas remains completely TRANSPARENT: no head, no face, no ears, no hair. No skirt, no cashew shirt print, no shoes; those are separate layers. Soft cream and warm peach colors, clean brown cartoon outlines matching the reference. Fill the missing torso rather than leaving holes. This hidden support layer will be covered by the existing shirt and skirt; original visible details will be retained above it. Transparent background, one registered body layer, no grid or text.

Review: use only within the hidden clothing mask. Original hands, legs and visible
silhouette come from the assembled candidate, not the generated approximation.

## `cosmetics/outfit_raincoat.png`

Input/edit target: `art/replacements/cosmetics/outfit_raincoat.png`. Supporting
reference: `art/replacements/baga/preview.png`. Transparent output requested.

> Use case: precise-object-edit. Edit target is image 1: sage raincoat cosmetic. Reference image 2 is Baga, the character who wears it. Make the same sage raincoat into a usable front-facing wearable overlay for Baga's short torso: fold the tall pointed hood DOWN behind the neck so there is just a low rounded folded collar, with an open small neckline. Keep the exact same sage paint, brown line work, two side pockets, little cream drawstrings and three gold buttons. Short sleeves must angle down to either side like the cream shirt on the character. Coat flares gently over waist to the top of the skirt, wider at bottom, cosy and stubby chibi proportions. ONLY the coat/collar/sleeves, empty transparent neckline, no body or face or hands, no character, no shirt or skirt. The coat alone should be roughly 1.5 times as wide as tall, no tall hood. Transparent background, crisp edges at sprite scale, same illustration style and identity as the supplied coat. One item, no shadow or text.

Review: approved; packing removes faint alpha matte outside the painted silhouette.
The runtime overlay and icon both use this refinement. An attempted separate head
backing was rejected by image generation and is not used; the supplied assembled
target provides the backing under the existing face layer instead.
