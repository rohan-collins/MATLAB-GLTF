function material_idx=addMaterial(gltf,varargin)
    % Add a physically-based rendering material.
    %
    % ADDMATERIAL(GLTF) adds an empty physically-based rendering material
    % to GLTF and returns its index.
    %
    % ADDMATERIAL(...,'name',NAME) sets the name of the material.
    %
    % ADDMATERIAL(...,'metallicFactor',METALLICFACTOR) sets the metallicity
    % of the material.
    %
    % ADDMATERIAL(...,'roughnessFactor',ROUGHNESSFACTOR) sets the roughness
    % of the material.
    %
    % ADDMATERIAL(...,'doubleSided',TRUE) makes the material double-sided
    % (faces are also visible when facing away from the camera).
    %
    % ADDMATERIAL(...,'alphaMode',ALPHAMODE) sets the the interpretation of
    % the alpha value of the base colour or the alpha channel of the base
    % colour texture.
    %
    % ADDMATERIAL(...,'baseColorFactor',BASECOLORFACTOR) sets the base
    % colour for the material.
    %
    % ADDMATERIAL(...,'baseColorTexture',FILENAME) uses the image specified
    % by FILENAME as the texture for the material. The image format needs
    % to be JPEG or PNG.
    %
    % ADDMATERIAL(...,'baseColorTextureSet',SET) uses the TEXCOORD SET as
    % the texture coordintes for the material base colour.
    %
    % ADDMATERIAL(...,'baseColorMagFilter',MAGFILTER) sets the
    % magnification filter for the base colour texture as per OpenGL.
    % MAGFILTER should be one of "NEAREST", "LINEAR",
    % "NEAREST_MIPMAP_NEAREST", "LINEAR_MIPMAP_NEAREST",
    % "NEAREST_MIPMAP_LINEAR", or "LINEAR_MIPMAP_LINEAR".
    %
    % ADDMATERIAL(...,'baseColorMinFilter',MINFILTER) sets the minification
    % filter for the base colour texture as per OpenGL. MINFILTER should be
    % one of "NEAREST", "LINEAR", "NEAREST_MIPMAP_NEAREST",
    % "LINEAR_MIPMAP_NEAREST", "NEAREST_MIPMAP_LINEAR", or
    % "LINEAR_MIPMAP_LINEAR".
    %
    % ADDMATERIAL(...,'baseColorWrapS',WRAPS) sets the wrapping of the U
    % coordinate of base colour texture as per OpenGL. WRAPS should be one
    % of "CLAMP_TO_EDGE", "MIRRORED_REPEAT", or "REPEAT".
    %
    % ADDMATERIAL(...,'baseColorWrapT',WRAPT) sets the wrapping of the V
    % coordinate of base colour texture as per OpenGL. WRAPT should be one
    % of "CLAMP_TO_EDGE", "MIRRORED_REPEAT", or "REPEAT".
    %
    % ADDMATERIAL(...,'baseColorEmbedTexture',FALSE) includes the base
    % colour texture image as a link inside the GLTF file.
    %
    % ADDMATERIAL(...,'normalTexture',FILENAME) uses the image specified by
    % FILENAME as the normal map for the material. The image format needs
    % to be JPEG or PNG.
    %
    % ADDMATERIAL(...,'normalTextureSet',SET) uses the TEXCOORD SET as the
    % texture coordintes for the material normal texture.
    %
    % ADDMATERIAL(...,'normalMagFilter',MAGFILTER) sets the magnification
    % filter for the normal texture as per OpenGL. MAGFILTER should be one
    % of "NEAREST", "LINEAR", "NEAREST_MIPMAP_NEAREST",
    % "LINEAR_MIPMAP_NEAREST", "NEAREST_MIPMAP_LINEAR", or
    % "LINEAR_MIPMAP_LINEAR".
    %
    % ADDMATERIAL(...,'normalMinFilter',MINFILTER) sets the minification
    % filter for the normal texture as per OpenGL. MINFILTER should be one
    % of "NEAREST", "LINEAR", "NEAREST_MIPMAP_NEAREST",
    % "LINEAR_MIPMAP_NEAREST", "NEAREST_MIPMAP_LINEAR", or
    % "LINEAR_MIPMAP_LINEAR".
    %
    % ADDMATERIAL(...,'normalWrapS',WRAPS) sets the wrapping of the U
    % coordinate of normal texture as per OpenGL. WRAPS should be one of
    % "CLAMP_TO_EDGE", "MIRRORED_REPEAT", or "REPEAT".
    %
    % ADDMATERIAL(...,'normalWrapT',WRAPT) sets the wrapping of the V
    % coordinate of normal as per OpenGL. WRAPT should be one of
    % "CLAMP_TO_EDGE", "MIRRORED_REPEAT", or "REPEAT".
    %
    % ADDMATERIAL(...,'normalEmbedTexture',FALSE) includes the normal
    % texture image as a link inside the GLTF file.
    %
    % ADDMATERIAL(...,'occlusionTexture',FILENAME) uses the image specified
    % by FILENAME as the occlusion map for the material. The image format
    % needs to be JPEG or PNG.
    %
    % ADDMATERIAL(...,'occlusionTextureSet',SET) uses the TEXCOORD SET as
    % the texture coordintes for the material occlusion.
    %
    % ADDMATERIAL(...,'occlusionMagFilter',MAGFILTER) sets the
    % magnification filter for the occlusion texture as per OpenGL.
    % MAGFILTER should be one of "NEAREST", "LINEAR",
    % "NEAREST_MIPMAP_NEAREST", "LINEAR_MIPMAP_NEAREST",
    % "NEAREST_MIPMAP_LINEAR", or "LINEAR_MIPMAP_LINEAR".
    %
    % ADDMATERIAL(...,'occlusionMinFilter',MINFILTER) sets the minification
    % filter for the occlusion texture as per OpenGL. MINFILTER should be
    % one of "NEAREST", "LINEAR", "NEAREST_MIPMAP_NEAREST",
    % "LINEAR_MIPMAP_NEAREST", "NEAREST_MIPMAP_LINEAR", or
    % "LINEAR_MIPMAP_LINEAR".
    %
    % ADDMATERIAL(...,'occlusionWrapS',WRAPS) sets the wrapping of the U
    % coordinate of occlusion texture as per OpenGL. WRAPS should be one of
    % "CLAMP_TO_EDGE", "MIRRORED_REPEAT", or "REPEAT".
    %
    % ADDMATERIAL(...,'occlusionWrapT',WRAPT) sets the wrapping of the V
    % coordinate of occlusion texture as per OpenGL. WRAPT should be one of
    % "CLAMP_TO_EDGE", "MIRRORED_REPEAT", or "REPEAT".
    %
    % ADDMATERIAL(...,'occlusionEmbedTexture',FALSE) includes the occlusion
    % texture image as a link inside the GLTF file.
    %
    % ADDMATERIAL(...,'emissiveFactor',EMISSIVEFACTOR) sets the base
    % emmisivity for the material.
    %
    % ADDMATERIAL(...,'emissiveStrength',EMISSIVESTRENGTH) sets the
    % strength adjustment to be multiplied with the material's emissive
    % value.
    %
    % ADDMATERIAL(...,'emissiveTexture',FILENAME) uses the image specified
    % by FILENAME as the emissive map for the material. The image format
    % needs to be JPEG or PNG.
    %
    % ADDMATERIAL(...,'emissiveTextureSet',SET) uses the TEXCOORD SET as
    % the texture coordintes for the material emissive.
    %
    % ADDMATERIAL(...,'emissiveMagFilter',MAGFILTER) sets the magnification
    % filter for the emissive texture as per OpenGL. MAGFILTER should be
    % one of "NEAREST", "LINEAR", "NEAREST_MIPMAP_NEAREST",
    % "LINEAR_MIPMAP_NEAREST", "NEAREST_MIPMAP_LINEAR", or
    % "LINEAR_MIPMAP_LINEAR".
    %
    % ADDMATERIAL(...,'emissiveMinFilter',MINFILTER) sets the minification
    % filter for the emissive texture as per OpenGL. MINFILTER should be
    % one of "NEAREST", "LINEAR", "NEAREST_MIPMAP_NEAREST",
    % "LINEAR_MIPMAP_NEAREST", "NEAREST_MIPMAP_LINEAR", or
    % "LINEAR_MIPMAP_LINEAR".
    %
    % ADDMATERIAL(...,'emissiveWrapS',WRAPS) sets the wrapping of the U
    % coordinate of emissive texture as per OpenGL. WRAPS should be one of
    % "CLAMP_TO_EDGE", "MIRRORED_REPEAT", or "REPEAT".
    %
    % ADDMATERIAL(...,'emissiveWrapT',WRAPT) sets the wrapping of the V
    % coordinate of emissive texture as per OpenGL. WRAPT should be one of
    % "CLAMP_TO_EDGE", "MIRRORED_REPEAT", or "REPEAT".
    %
    % ADDMATERIAL(...,'emissiveEmbedTexture',FALSE) includes the emissive
    % texture image as a link inside the GLTF file.
    %
    % ADDMATERIAL(...,'transmissionFactor',TRANSMISSIONFACTOR) sets the
    % base transmission factor for the material.
    %
    % ADDMATERIAL(...,'transmissionTexture',FILENAME) uses the R channel of
    % the image specified by FILENAME as the transmission map for the
    % material. The image format needs to be JPEG or PNG.
    %
    % ADDMATERIAL(...,'transmissionTextureSet',SET) uses the TEXCOORD SET
    % as the texture coordintes for the material transmission.
    %
    % ADDMATERIAL(...,'transmissionMagFilter',MAGFILTER) sets the
    % magnification filter for the transmission texture as per OpenGL.
    % MAGFILTER should be one of "NEAREST", "LINEAR",
    % "NEAREST_MIPMAP_NEAREST", "LINEAR_MIPMAP_NEAREST",
    % "NEAREST_MIPMAP_LINEAR", or "LINEAR_MIPMAP_LINEAR".
    %
    % ADDMATERIAL(...,'transmissionMinFilter',MINFILTER) sets the
    % minification filter for the transmission texture as per OpenGL.
    % MINFILTER should be one of "NEAREST", "LINEAR",
    % "NEAREST_MIPMAP_NEAREST", "LINEAR_MIPMAP_NEAREST",
    % "NEAREST_MIPMAP_LINEAR", or "LINEAR_MIPMAP_LINEAR".
    %
    % ADDMATERIAL(...,'transmissionWrapS',WRAPS) sets the wrapping of the U
    % coordinate of transmission texture as per OpenGL. WRAPS should be one
    % of "CLAMP_TO_EDGE", "MIRRORED_REPEAT", or "REPEAT".
    %
    % ADDMATERIAL(...,'transmissionWrapT',WRAPT) sets the wrapping of the V
    % coordinate of transmission texture as per OpenGL. WRAPT should be one
    % of "CLAMP_TO_EDGE", "MIRRORED_REPEAT", or "REPEAT".
    %
    % ADDMATERIAL(...,'transmissionEmbedTexture',FALSE) includes the
    % transmission texture image as a link inside the GLTF file.
    %
    % ADDMATERIAL(...,'ior',IOR) sets the index of refraction for the
    % material. If IOR is an empty array, value is not added, but the
    % KHR_materials_ior extension is still enabled, the renderer will use
    % default value of 1.5.
    %
    % ADDMATERIAL(...,'thicknessFactor',THICKNESS) sets the base thickness
    % factor for the material. The value is given in the coordinate space
    % of the mesh. If the value is 0 the material is thin-walled. Otherwise
    % the material is a volume boundary. The doubleSided property has no
    % effect on volume boundaries.
    %
    % ADDMATERIAL(...,'thicknessTexture',FILENAME) uses the G channel of
    % the image specified by FILENAME as the thickness map for the
    % material. The image format needs to be JPEG or PNG.
    %
    % ADDMATERIAL(...,'thicknessTextureSet',SET) uses the TEXCOORD SET as
    % the texture coordintes for the material thickness.
    %
    % ADDMATERIAL(...,'thicknessMagFilter',MAGFILTER) sets the
    % magnification filter for the thickness texture as per OpenGL.
    % MAGFILTER should be one of "NEAREST", "LINEAR",
    % "NEAREST_MIPMAP_NEAREST", "LINEAR_MIPMAP_NEAREST",
    % "NEAREST_MIPMAP_LINEAR", or "LINEAR_MIPMAP_LINEAR".
    %
    % ADDMATERIAL(...,'thicknessMinFilter',MINFILTER) sets the minification
    % filter for the thickness texture as per OpenGL. MINFILTER should be
    % one of "NEAREST", "LINEAR", "NEAREST_MIPMAP_NEAREST",
    % "LINEAR_MIPMAP_NEAREST", "NEAREST_MIPMAP_LINEAR", or
    % "LINEAR_MIPMAP_LINEAR".
    %
    % ADDMATERIAL(...,'thicknessWrapS',WRAPS) sets the wrapping of the U
    % coordinate of thickness texture as per OpenGL. WRAPS should be one of
    % "CLAMP_TO_EDGE", "MIRRORED_REPEAT", or "REPEAT".
    %
    % ADDMATERIAL(...,'thicknessWrapT',WRAPT) sets the wrapping of the V
    % coordinate of thickness texture as per OpenGL. WRAPT should be one of
    % "CLAMP_TO_EDGE", "MIRRORED_REPEAT", or "REPEAT".
    %
    % ADDMATERIAL(...,'thicknessEmbedTexture',FALSE) includes the thickness
    % texture image as a link inside the GLTF file.
    %
    % ADDMATERIAL(...,'attenuationDistance',ATTENUATIONDISTANCE) sets the
    % density of the medium given as the average distance that light
    % travels in the medium before interacting with a particle. The value
    % is given in world space.
    %
    % ADDMATERIAL(...,'attenuationColor',ATTENUATIONCOLOR) sets the color
    % that white light turns into due to absorption when reaching the
    % attenuation distance.
    %
    % ADDMATERIAL(...,'clearcoatFactor',CLEARCOATFACTOR) sets the base
    % clearcoat layer intensity.
    %
    % ADDMATERIAL(...,'clearcoatTexture',FILENAME) uses the image specified
    % by FILENAME as the clearcoat layer intensity texture. The image
    % format needs to be JPEG or PNG.
    %
    % ADDMATERIAL(...,'clearcoatTextureTextureSet',SET) uses the TEXCOORD
    % SET as the texture coordintes for the material clearcoat texture.
    %
    % ADDMATERIAL(...,'clearcoatTextureMagFilter',MAGFILTER) sets the
    % magnification filter for the clearcoat texture as per OpenGL.
    % MAGFILTER should be one of "NEAREST", "LINEAR",
    % "NEAREST_MIPMAP_NEAREST", "LINEAR_MIPMAP_NEAREST",
    % "NEAREST_MIPMAP_LINEAR", or "LINEAR_MIPMAP_LINEAR".
    %
    % ADDMATERIAL(...,'clearcoatTextureMinFilter',MINFILTER) sets the
    % minification filter for the clearcoat texture as per OpenGL.
    % MINFILTER should be one of "NEAREST", "LINEAR",
    % "NEAREST_MIPMAP_NEAREST", "LINEAR_MIPMAP_NEAREST",
    % "NEAREST_MIPMAP_LINEAR", or "LINEAR_MIPMAP_LINEAR".
    %
    % ADDMATERIAL(...,'clearcoatTextureWrapS',WRAPS) sets the wrapping of
    % the U coordinate of clearcoat texture as per OpenGL. WRAPS should be
    % one of "CLAMP_TO_EDGE", "MIRRORED_REPEAT", or "REPEAT".
    %
    % ADDMATERIAL(...,'clearcoatTextureWrapT',WRAPT) sets the wrapping of
    % the V coordinate of clearcoat texture as per OpenGL. WRAPT should be
    % one of "CLAMP_TO_EDGE", "MIRRORED_REPEAT", or "REPEAT".
    %
    % ADDMATERIAL(...,'clearcoatEmbedTexture',FALSE) includes the clearcoat
    % texture image as a link inside the GLTF file.
    %
    % ADDMATERIAL(...,'clearcoatRoughnessFactor', CLEARCOATROUGHNESSFACTOR)
    % sets the base clearcoat layer roughness.
    %
    % ADDMATERIAL(...,'clearcoatRoughnessTexture',FILENAME) uses the image
    % specified by FILENAME as the clearcoat layer roughness texture. The
    % image format needs to be JPEG or PNG.
    %
    % ADDMATERIAL(...,'clearcoatRoughnessTextureTextureSet',SET) uses the
    % TEXCOORD SET as the texture coordintes for the material clearcoat
    % roughness texture.
    %
    % ADDMATERIAL(...,'clearcoatRoughnessTextureMagFilter',MAGFILTER) sets
    % the magnification filter for the clearcoat roughness texture as per
    % OpenGL. MAGFILTER should be one of "NEAREST", "LINEAR",
    % "NEAREST_MIPMAP_NEAREST", "LINEAR_MIPMAP_NEAREST",
    % "NEAREST_MIPMAP_LINEAR", or "LINEAR_MIPMAP_LINEAR".
    %
    % ADDMATERIAL(...,'clearcoatRoughnessTextureMinFilter',MINFILTER) sets
    % the minification filter for the clearcoat roughness texture as per
    % OpenGL. MINFILTER should be one of "NEAREST", "LINEAR",
    % "NEAREST_MIPMAP_NEAREST", "LINEAR_MIPMAP_NEAREST",
    % "NEAREST_MIPMAP_LINEAR", or "LINEAR_MIPMAP_LINEAR".
    %
    % ADDMATERIAL(...,'clearcoatRoughnessTextureWrapS',WRAPS) sets the
    % wrapping of the U coordinate of clearcoat roughness texture as per
    % OpenGL. WRAPS should be one of "CLAMP_TO_EDGE", "MIRRORED_REPEAT", or
    % "REPEAT".
    %
    % ADDMATERIAL(...,'clearcoatRoughnessTextureWrapT',WRAPT) sets the
    % wrapping of the V coordinate of clearcoat roughness texture as per
    % OpenGL. WRAPT should be one of "CLAMP_TO_EDGE", "MIRRORED_REPEAT", or
    % "REPEAT".
    %
    % ADDMATERIAL(...,'clearcoatRoughnessEmbedTexture',FALSE) includes the
    % clearcoat roughness texture image as a link inside the GLTF file.
    %
    % ADDMATERIAL(...,'clearcoatNormalTexture',FILENAME) uses the image
    % specified by FILENAME as the clearcoat layer normal map texture. The
    % image format needs to be JPEG or PNG.
    %
    % ADDMATERIAL(...,'clearcoatNormalTextureTextureSet',SET) uses the
    % TEXCOORD SET as the texture coordintes for the material clearcoat
    % normal.
    %
    % ADDMATERIAL(...,'clearcoatNormalTextureMagFilter',MAGFILTER) sets the
    % magnification filter for the clearcoat normal texture as per OpenGL.
    % MAGFILTER should be one of "NEAREST", "LINEAR",
    % "NEAREST_MIPMAP_NEAREST", "LINEAR_MIPMAP_NEAREST",
    % "NEAREST_MIPMAP_LINEAR", or "LINEAR_MIPMAP_LINEAR".
    %
    % ADDMATERIAL(...,'clearcoatNormalTextureMinFilter',MINFILTER) sets the
    % minification filter for the clearcoat normal texture as per OpenGL.
    % MINFILTER should be one of "NEAREST", "LINEAR",
    % "NEAREST_MIPMAP_NEAREST", "LINEAR_MIPMAP_NEAREST",
    % "NEAREST_MIPMAP_LINEAR", or "LINEAR_MIPMAP_LINEAR".
    %
    % ADDMATERIAL(...,'clearcoatNormalTextureWrapS',WRAPS) sets the
    % wrapping of the U coordinate of clearcoat normal texture as per
    % OpenGL. WRAPS should be one of "CLAMP_TO_EDGE", "MIRRORED_REPEAT", or
    % "REPEAT".
    %
    % ADDMATERIAL(...,'clearcoatNormalTextureWrapT',WRAPT) sets the
    % wrapping of the V coordinate of clearcoat normal texture as per
    % OpenGL. WRAPT should be one of "CLAMP_TO_EDGE", "MIRRORED_REPEAT", or
    % "REPEAT".
    %
    % ADDMATERIAL(...,'clearcoatNormalEmbedTexture',FALSE) includes the
    % clearcoat normal texture image as a link inside the GLTF file.
    %
    % ADDMATERIAL(...,'sheenColorFactor',SHEENCOLORFACTOR) sets the base
    % sheen color for the material.
    %
    % ADDMATERIAL(...,'sheenColorTexture',FILENAME) uses the RGB channels
    % of the image specified by FILENAME as the sheen colour for the
    % material. The image format needs to be JPEG or PNG.
    %
    % ADDMATERIAL(...,'sheenColorTextureSet',SET) uses the TEXCOORD SET as
    % the texture coordintes for the material sheen colour.
    %
    % ADDMATERIAL(...,'sheenColorMagFilter',MAGFILTER) sets the
    % magnification filter for the sheen colour texture as per OpenGL.
    % MAGFILTER should be one of "NEAREST", "LINEAR",
    % "NEAREST_MIPMAP_NEAREST", "LINEAR_MIPMAP_NEAREST",
    % "NEAREST_MIPMAP_LINEAR", or "LINEAR_MIPMAP_LINEAR".
    %
    % ADDMATERIAL(...,'sheenColorMinFilter',MINFILTER) sets the
    % minification filter for the sheen colour texture as per OpenGL.
    % MINFILTER should be one of "NEAREST", "LINEAR",
    % "NEAREST_MIPMAP_NEAREST", "LINEAR_MIPMAP_NEAREST",
    % "NEAREST_MIPMAP_LINEAR", or "LINEAR_MIPMAP_LINEAR".
    %
    % ADDMATERIAL(...,'sheenColorWrapS',WRAPS) sets the wrapping of the U
    % coordinate of sheen colour texture as per OpenGL. WRAPS should be one
    % of "CLAMP_TO_EDGE", "MIRRORED_REPEAT", or "REPEAT".
    %
    % ADDMATERIAL(...,'sheenColorWrapT',WRAPT) sets the wrapping of the V
    % coordinate of sheen colour texture as per OpenGL. WRAPT should be one
    % of "CLAMP_TO_EDGE", "MIRRORED_REPEAT", or "REPEAT".
    %
    % ADDMATERIAL(...,'sheenColorEmbedTexture',FALSE) includes the sheen
    % color texture image as a link inside the GLTF file.
    %
    % ADDMATERIAL(...,'sheenRoughnessFactor',SHEENROUGHNESSFACTOR) sets the
    % base sheen roughness for the material.
    %
    % ADDMATERIAL(...,'sheenRoughnessTexture',FILENAME) uses the A channel
    % of the image specified by FILENAME as the sheen colour for the
    % material. The image format needs to be PNG.
    %
    % ADDMATERIAL(...,'sheenRoughnessTextureSet',SET) uses the TEXCOORD SET
    % as the texture coordintes for the material sheen roughness.
    %
    % ADDMATERIAL(...,'sheenRoughnessMagFilter',MAGFILTER) sets the
    % magnification filter for the sheen roughness texture as per OpenGL.
    % MAGFILTER should be one of "NEAREST", "LINEAR",
    % "NEAREST_MIPMAP_NEAREST", "LINEAR_MIPMAP_NEAREST",
    % "NEAREST_MIPMAP_LINEAR", or "LINEAR_MIPMAP_LINEAR".
    %
    % ADDMATERIAL(...,'sheenRoughnessMinFilter',MINFILTER) sets the
    % minification filter for the sheen roughness texture as per OpenGL.
    % MINFILTER should be one of "NEAREST", "LINEAR",
    % "NEAREST_MIPMAP_NEAREST", "LINEAR_MIPMAP_NEAREST",
    % "NEAREST_MIPMAP_LINEAR", or "LINEAR_MIPMAP_LINEAR".
    %
    % ADDMATERIAL(...,'sheenRoughnessWrapS',WRAPS) sets the wrapping of the
    % U coordinate of sheen roughness texture as per OpenGL. WRAPS should
    % be one of "CLAMP_TO_EDGE", "MIRRORED_REPEAT", or "REPEAT".
    %
    % ADDMATERIAL(...,'sheenRoughnessWrapT',WRAPT) sets the wrapping of the
    % V coordinate of sheen roughness texture as per OpenGL. WRAPT should
    % be one of "CLAMP_TO_EDGE", "MIRRORED_REPEAT", or "REPEAT".
    %
    % ADDMATERIAL(...,'sheenRoughnessEmbedTexture',FALSE) includes the
    % sheen roughness texture image as a link inside the GLTF file.
    %
    % ADDMATERIAL(...,'specularFactor',SPECULARFACTOR) sets the base
    % strength of the specular reflection.
    %
    % ADDMATERIAL(...,'specularTexture',FILENAME) uses the A channel of the
    % image specified by FILENAME as the strength of the specular
    % reflection for the material. The image format needs to be PNG.
    %
    % ADDMATERIAL(...,'specularTextureSet',SET) uses the TEXCOORD SET as
    % the texture coordintes for the material specular texture.
    %
    % ADDMATERIAL(...,'specularMagFilter',MAGFILTER) sets the magnification
    % filter for the specular texture as per OpenGL. MAGFILTER should be
    % one of "NEAREST", "LINEAR", "NEAREST_MIPMAP_NEAREST",
    % "LINEAR_MIPMAP_NEAREST", "NEAREST_MIPMAP_LINEAR", or
    % "LINEAR_MIPMAP_LINEAR".
    %
    % ADDMATERIAL(...,'specularMinFilter',MINFILTER) sets the minification
    % filter for the specular texture as per OpenGL. MINFILTER should be
    % one of "NEAREST", "LINEAR", "NEAREST_MIPMAP_NEAREST",
    % "LINEAR_MIPMAP_NEAREST", "NEAREST_MIPMAP_LINEAR", or
    % "LINEAR_MIPMAP_LINEAR".
    %
    % ADDMATERIAL(...,'specularWrapS',WRAPS) sets the wrapping of the U
    % coordinate of specular texture as per OpenGL. WRAPS should be one of
    % "CLAMP_TO_EDGE", "MIRRORED_REPEAT", or "REPEAT".
    %
    % ADDMATERIAL(...,'specularWrapT',WRAPT) sets the wrapping of the V
    % coordinate of specular texture as per OpenGL. WRAPT should be one of
    % "CLAMP_TO_EDGE", "MIRRORED_REPEAT", or "REPEAT".
    %
    % ADDMATERIAL(...,'specularEmbedTexture',FALSE) includes the specular
    % texture image as a link inside the GLTF file.
    %
    % ADDMATERIAL(...,'specularColorFactor',specularColorFactor) sets the
    % base F0 color of the specular reflection.
    %
    % ADDMATERIAL(...,'specularColorTexture',FILENAME) uses the RGB
    % channels of the image specified by FILENAME as the F0 color of the
    % specular reflection. The image format needs to be JPEG or PNG.
    %
    % ADDMATERIAL(...,'specularColorTextureSet',SET) uses the TEXCOORD SET
    % as the texture coordintes for the material specular colour.
    %
    % ADDMATERIAL(...,'specularColorMagFilter',MAGFILTER) sets the
    % magnification filter for the specular colour texture as per OpenGL.
    % MAGFILTER should be one of "NEAREST", "LINEAR",
    % "NEAREST_MIPMAP_NEAREST", "LINEAR_MIPMAP_NEAREST",
    % "NEAREST_MIPMAP_LINEAR", or "LINEAR_MIPMAP_LINEAR".
    %
    % ADDMATERIAL(...,'specularColorMinFilter',MINFILTER) sets the
    % minification filter for the specular colour texture as per OpenGL.
    % MINFILTER should be one of "NEAREST", "LINEAR",
    % "NEAREST_MIPMAP_NEAREST", "LINEAR_MIPMAP_NEAREST",
    % "NEAREST_MIPMAP_LINEAR", or "LINEAR_MIPMAP_LINEAR".
    %
    % ADDMATERIAL(...,'specularColorWrapS',WRAPS) sets the wrapping of the
    % U coordinate of specular colour texture as per OpenGL. WRAPS should
    % be one of "CLAMP_TO_EDGE", "MIRRORED_REPEAT", or "REPEAT".
    %
    % ADDMATERIAL(...,'specularColorWrapT',WRAPT) sets the wrapping of the
    % V coordinate of specular colour texture as per OpenGL. WRAPT should
    % be one of "CLAMP_TO_EDGE", "MIRRORED_REPEAT", or "REPEAT".
    %
    % ADDMATERIAL(...,'specularColorEmbedTexture',FALSE) includes the
    % specular colour texture image as a link inside the GLTF file.
    %
    % ADDMATERIAL(...,'unlit',TRUE) sets the material as a constantly
    % shaded surface that is independent of lighting.
    %
    % ADDMATERIAL(...,'iridescenceFactor',IRIDESCENCeFACTOR) sets the
    % iridescence intensity factor.
    %
    % ADDMATERIAL(...,'iridescenceTexture',FILENAME) uses the image
    % specified by FILENAME as the iridescence intensity texture for the
    % material. The image format needs to be JPEG or PNG.
    %
    % ADDMATERIAL(...,'iridescenceTextureSet',SET) uses the TEXCOORD SET as
    % the texture coordintes for the material iridescence intensity.
    %
    % ADDMATERIAL(...,'iridescenceIor',IOR) sets the index of refraction of
    % the dielectric thin-film layer.
    %
    % ADDMATERIAL(...,'iridescenceThicknessMinimum',THICKNESSMINIMUM) sets
    % the minimum thickness of the thin-film layer given in nanometers.
    %
    % ADDMATERIAL(...,'iridescenceThicknessMaximum',THICKNESSMAXIMUM) sets
    % the maximum thickness of the thin-film layer given in nanometers.
    %
    % ADDMATERIAL(...,'iridescenceMagFilter',MAGFILTER) sets the
    % magnification filter for the iridescence intensity texture as per
    % OpenGL. MAGFILTER should be one of "NEAREST", "LINEAR",
    % "NEAREST_MIPMAP_NEAREST", "LINEAR_MIPMAP_NEAREST",
    % "NEAREST_MIPMAP_LINEAR", or "LINEAR_MIPMAP_LINEAR". 
    %
    % ADDMATERIAL(...,'iridescenceMinFilter',MINFILTER) sets the
    % minification filter for the iridescence intensity texture as per
    % OpenGL. MAGFILTER should be one of "NEAREST", "LINEAR",
    % "NEAREST_MIPMAP_NEAREST", "LINEAR_MIPMAP_NEAREST",
    % "NEAREST_MIPMAP_LINEAR", or "LINEAR_MIPMAP_LINEAR".
    %
    % ADDMATERIAL(...,'iridescenceWrapS',WRAPS) sets the wrapping of the U
    % coordinate of iridescence intensity texture as per OpenGL. WRAPS
    % should be one of "CLAMP_TO_EDGE", "MIRRORED_REPEAT", or "REPEAT".
    %
    % ADDMATERIAL(...,'iridescenceWrapT',WRAPT) sets the wrapping of the V
    % coordinate of iridescence intensity texture as per OpenGL. WRAPS
    % should be one of "CLAMP_TO_EDGE", "MIRRORED_REPEAT", or "REPEAT".
    %
    % ADDMATERIAL(...,'iridescenceEmbedTexture',FALSE) includes the
    % iridescence intensity texture image as a link inside the GLTF file.
    %
    % ADDMATERIAL(...,'iridescenceThicknessTexture',FILENAME) uses the
    % image specified by FILENAME as the thickness texture of the thin-film
    % layer for the material. The image format needs to be JPEG or PNG.
    %
    % ADDMATERIAL(...,'iridescenceThicknessTextureSet',SET) uses the
    % TEXCOORD SET as the texture coordintes for the thin-film layer
    % thickness of the material.
    %
    % ADDMATERIAL(...,'iridescenceThicknessMagFilter',MAGFILTER) sets the
    % magnification filter for the thickness texture of the thin-film layer
    % as per OpenGL. MAGFILTER should be one of "NEAREST", "LINEAR",
    % "NEAREST_MIPMAP_NEAREST", "LINEAR_MIPMAP_NEAREST",
    % "NEAREST_MIPMAP_LINEAR", or "LINEAR_MIPMAP_LINEAR".
    %
    % ADDMATERIAL(...,'iridescenceThicknessMinFilter',MINFILTER) sets the
    % minification filter for the thickness texture of the thin-film layer
    % as per OpenGL. MAGFILTER should be one of "NEAREST", "LINEAR",
    % "NEAREST_MIPMAP_NEAREST", "LINEAR_MIPMAP_NEAREST",
    % "NEAREST_MIPMAP_LINEAR", or "LINEAR_MIPMAP_LINEAR".
    %
    % ADDMATERIAL(...,'iridescenceThicknessWrapS',WRAPS) sets the wrapping
    % of the U coordinate of thickness texture of the thin-film layer as
    % per OpenGL. WRAPS should be one of "CLAMP_TO_EDGE",
    % "MIRRORED_REPEAT", or "REPEAT".
    %
    % ADDMATERIAL(...,'iridescenceThicknessWrapT',WRAPT) sets the wrapping
    % of the V coordinate of thickness texture of the thin-film layer as
    % per OpenGL. WRAPS should be one of "CLAMP_TO_EDGE",
    % "MIRRORED_REPEAT", or "REPEAT".
    %
    % ADDMATERIAL(...,'iridescenceThicknessEmbedTexture',FALSE) includes
    % the thickness texture image of the thin-film layer as a link inside
    % the GLTF file.
    %
    % © Copyright 2014-2023 Rohan Chabukswar
    %
    % This file is part of MATLAB GLTF.
    %
    % MATLAB GLTF is free software: you can redistribute it and/or modify
    % it under the terms of the GNU General Public License as published by
    % the Free Software Foundation, either version 3 of the License, or (at
    % your option) any later version.
    %
    % MATLAB GLTF is distributed in the hope that it will be useful, but
    % WITHOUT ANY WARRANTY; without even the implied warranty of
    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
    % General Public License for more details.
    %
    % You should have received a copy of the GNU General Public License
    % along with MATLAB GLTF. If not, see <https://www.gnu.org/licenses/>.
    %
    filter_str_values=["NEAREST","LINEAR","NEAREST_MIPMAP_NEAREST","LINEAR_MIPMAP_NEAREST","NEAREST_MIPMAP_LINEAR","LINEAR_MIPMAP_LINEAR"];
    wrap_str_values=["CLAMP_TO_EDGE","MIRRORED_REPEAT","REPEAT"];
    alphaMode_str_values=["OPAQUE","MASK","BLEND"];
    ips=inputParser;
    ips.addParameter('name',missing,@isstring);
    ips.addParameter('baseColorFactor',[],@isnumeric);
    ips.addParameter('metallicFactor',[],@isnumeric);
    ips.addParameter('roughnessFactor',[],@isnumeric);
    ips.addParameter('doubleSided',[],@islogical);
    ips.addParameter('alphaMode',missing,@(x)GLTF.validateString(x,alphaMode_str_values));
    ips.addParameter('baseColorTexture',missing,@isstring);
    ips.addParameter('baseColorTextureSet',nan,@isnumeric);
    ips.addParameter('baseColorMagFilter',missing,@(x)GLTF.validateString(x,filter_str_values));
    ips.addParameter('baseColorMinFilter',missing,@(x)GLTF.validateString(x,filter_str_values));
    ips.addParameter('baseColorWrapS',missing,@(x)GLTF.validateString(x,wrap_str_values));
    ips.addParameter('baseColorWrapT',missing,@(x)GLTF.validateString(x,wrap_str_values));
    ips.addParameter('baseColorEmbedTexture',true,@islogical);
    ips.addParameter('normalTexture',missing,@isstring);
    ips.addParameter('normalTextureSet',nan,@isnumeric);
    ips.addParameter('normalMagFilter',missing,@(x)GLTF.validateString(x,filter_str_values));
    ips.addParameter('normalMinFilter',missing,@(x)GLTF.validateString(x,filter_str_values));
    ips.addParameter('normalWrapS',missing,@(x)GLTF.validateString(x,wrap_str_values));
    ips.addParameter('normalWrapT',missing,@(x)GLTF.validateString(x,wrap_str_values));
    ips.addParameter('normalEmbedTexture',true,@islogical);
    ips.addParameter('occlusionTexture',missing,@isstring);
    ips.addParameter('occlusionTextureSet',nan,@isnumeric);
    ips.addParameter('occlusionMagFilter',missing,@(x)GLTF.validateString(x,filter_str_values));
    ips.addParameter('occlusionMinFilter',missing,@(x)GLTF.validateString(x,filter_str_values));
    ips.addParameter('occlusionWrapS',missing,@(x)GLTF.validateString(x,wrap_str_values));
    ips.addParameter('occlusionWrapT',missing,@(x)GLTF.validateString(x,wrap_str_values));
    ips.addParameter('occlusionEmbedTexture',true,@islogical);
    ips.addParameter('emissiveFactor',[],@isnumeric);
    ips.addParameter('emissiveTexture',missing,@isstring);
    ips.addParameter('emissiveTextureSet',nan,@isnumeric);
    ips.addParameter('emissiveMagFilter',missing,@(x)GLTF.validateString(x,filter_str_values));
    ips.addParameter('emissiveMinFilter',missing,@(x)GLTF.validateString(x,filter_str_values));
    ips.addParameter('emissiveWrapS',missing,@(x)GLTF.validateString(x,wrap_str_values));
    ips.addParameter('emissiveWrapT',missing,@(x)GLTF.validateString(x,wrap_str_values));
    ips.addParameter('emissiveEmbedTexture',true,@islogical);
    ips.addParameter('emissiveStrength',[],@isnumeric);
    ips.addParameter('transmissionFactor',[],@isnumeric);
    ips.addParameter('transmissionTexture',missing,@isstring);
    ips.addParameter('transmissionTextureSet',nan,@isnumeric);
    ips.addParameter('transmissionMagFilter',missing,@(x)GLTF.validateString(x,filter_str_values));
    ips.addParameter('transmissionMinFilter',missing,@(x)GLTF.validateString(x,filter_str_values));
    ips.addParameter('transmissionWrapS',missing,@(x)GLTF.validateString(x,wrap_str_values));
    ips.addParameter('transmissionWrapT',missing,@(x)GLTF.validateString(x,wrap_str_values));
    ips.addParameter('transmissionEmbedTexture',true,@islogical);
    ips.addParameter('thicknessFactor',[],@isnumeric);
    ips.addParameter('thicknessTexture',missing,@isstring);
    ips.addParameter('thicknessTextureSet',nan,@isnumeric);
    ips.addParameter('thicknessMagFilter',missing,@(x)GLTF.validateString(x,filter_str_values));
    ips.addParameter('thicknessMinFilter',missing,@(x)GLTF.validateString(x,filter_str_values));
    ips.addParameter('thicknessWrapS',missing,@(x)GLTF.validateString(x,wrap_str_values));
    ips.addParameter('thicknessWrapT',missing,@(x)GLTF.validateString(x,wrap_str_values));
    ips.addParameter('thicknessEmbedTexture',true,@islogical);
    ips.addParameter('attenuationDistance',[],@isnumeric);
    ips.addParameter('attenuationColor',[],@isnumeric);
    ips.addParameter('ior',[],@isnumeric);
    ips.addParameter('clearcoatFactor',[],@isnumeric);
    ips.addParameter('clearcoatTexture',missing,@isstring);
    ips.addParameter('clearcoatTextureSet',nan,@isnumeric);
    ips.addParameter('clearcoatMagFilter',missing,@(x)GLTF.validateString(x,filter_str_values));
    ips.addParameter('clearcoatMinFilter',missing,@(x)GLTF.validateString(x,filter_str_values));
    ips.addParameter('clearcoatWrapS',missing,@(x)GLTF.validateString(x,wrap_str_values));
    ips.addParameter('clearcoatWrapT',missing,@(x)GLTF.validateString(x,wrap_str_values));
    ips.addParameter('clearcoatEmbedTexture',true,@islogical);
    ips.addParameter('clearcoatRoughnessFactor',[],@isnumeric);
    ips.addParameter('clearcoatRoughnessTexture',missing,@isstring);
    ips.addParameter('clearcoatRoughnessTextureSet',nan,@isnumeric);
    ips.addParameter('clearcoatRoughnessMagFilter',missing,@(x)GLTF.validateString(x,filter_str_values));
    ips.addParameter('clearcoatRoughnessMinFilter',missing,@(x)GLTF.validateString(x,filter_str_values));
    ips.addParameter('clearcoatRoughnessWrapS',missing,@(x)GLTF.validateString(x,wrap_str_values));
    ips.addParameter('clearcoatRoughnessWrapT',missing,@(x)GLTF.validateString(x,wrap_str_values));
    ips.addParameter('clearcoatRoughnessEmbedTexture',true,@islogical);
    ips.addParameter('clearcoatNormalTexture',missing,@isstring);
    ips.addParameter('clearcoatNormalTextureSet',nan,@isnumeric);
    ips.addParameter('clearcoatNormalMagFilter',missing,@(x)GLTF.validateString(x,filter_str_values));
    ips.addParameter('clearcoatNormalMinFilter',missing,@(x)GLTF.validateString(x,filter_str_values));
    ips.addParameter('clearcoatNormalWrapS',missing,@(x)GLTF.validateString(x,wrap_str_values));
    ips.addParameter('clearcoatNormalWrapT',missing,@(x)GLTF.validateString(x,wrap_str_values));
    ips.addParameter('clearcoatNormalEmbedTexture',true,@islogical);
    ips.addParameter('sheenColorFactor',[],@isnumeric);
    ips.addParameter('sheenColorTexture',missing,@isstring);
    ips.addParameter('sheenColorTextureSet',nan,@isnumeric);
    ips.addParameter('sheenColorMagFilter',missing,@(x)GLTF.validateString(x,filter_str_values));
    ips.addParameter('sheenColorMinFilter',missing,@(x)GLTF.validateString(x,filter_str_values));
    ips.addParameter('sheenColorWrapS',missing,@(x)GLTF.validateString(x,wrap_str_values));
    ips.addParameter('sheenColorWrapT',missing,@(x)GLTF.validateString(x,wrap_str_values));
    ips.addParameter('sheenColorEmbedTexture',true,@islogical);
    ips.addParameter('sheenRoughnessFactor',[],@isnumeric);
    ips.addParameter('sheenRoughnessTexture',missing,@isstring);
    ips.addParameter('sheenRoughnessTextureSet',nan,@isnumeric);
    ips.addParameter('sheenRoughnessMagFilter',missing,@(x)GLTF.validateString(x,filter_str_values));
    ips.addParameter('sheenRoughnessMinFilter',missing,@(x)GLTF.validateString(x,filter_str_values));
    ips.addParameter('sheenRoughnessWrapS',missing,@(x)GLTF.validateString(x,wrap_str_values));
    ips.addParameter('sheenRoughnessWrapT',missing,@(x)GLTF.validateString(x,wrap_str_values));
    ips.addParameter('sheenRoughnessEmbedTexture',true,@islogical);
    ips.addParameter('specularFactor',[],@isnumeric);
    ips.addParameter('specularTexture',missing,@isstring);
    ips.addParameter('specularTextureSet',nan,@isnumeric);
    ips.addParameter('specularMagFilter',missing,@(x)GLTF.validateString(x,filter_str_values));
    ips.addParameter('specularMinFilter',missing,@(x)GLTF.validateString(x,filter_str_values));
    ips.addParameter('specularWrapS',missing,@(x)GLTF.validateString(x,wrap_str_values));
    ips.addParameter('specularWrapT',missing,@(x)GLTF.validateString(x,wrap_str_values));
    ips.addParameter('specularEmbedTexture',true,@islogical);
    ips.addParameter('specularColorFactor',[],@isnumeric);
    ips.addParameter('specularColorTexture',missing,@isstring);
    ips.addParameter('specularColorTextureSet',nan,@isnumeric);
    ips.addParameter('specularColorMagFilter',missing,@(x)GLTF.validateString(x,filter_str_values));
    ips.addParameter('specularColorMinFilter',missing,@(x)GLTF.validateString(x,filter_str_values));
    ips.addParameter('specularColorWrapS',missing,@(x)GLTF.validateString(x,wrap_str_values));
    ips.addParameter('specularColorWrapT',missing,@(x)GLTF.validateString(x,wrap_str_values));
    ips.addParameter('specularColorEmbedTexture',true,@islogical);
    ips.addParameter('unlit',false,@islogical);
    ips.addParameter('iridescenceFactor',[],@isnumeric);
    ips.addParameter('iridescenceTexture',missing,@isstring);
    ips.addParameter('iridescenceTextureSet',nan,@isnumeric);
    ips.addParameter('iridescenceIor',[],@isnumeric);
    ips.addParameter('iridescenceThicknessMinimum',[],@isnumeric);
    ips.addParameter('iridescenceThicknessMaximum',[],@isnumeric);
    ips.addParameter('iridescenceMagFilter',missing,@(x)GLTF.validateString(x,filter_str_values));
    ips.addParameter('iridescenceMinFilter',missing,@(x)GLTF.validateString(x,filter_str_values));
    ips.addParameter('iridescenceWrapS',missing,@(x)GLTF.validateString(x,wrap_str_values));
    ips.addParameter('iridescenceWrapT',missing,@(x)GLTF.validateString(x,wrap_str_values));
    ips.addParameter('iridescenceEmbedTexture',true,@islogical);
    ips.addParameter('iridescenceThicknessTexture',missing,@isstring);
    ips.addParameter('iridescenceThicknessTextureSet',nan,@isnumeric);
    ips.addParameter('iridescenceThicknessMagFilter',missing,@(x)GLTF.validateString(x,filter_str_values));
    ips.addParameter('iridescenceThicknessMinFilter',missing,@(x)GLTF.validateString(x,filter_str_values));
    ips.addParameter('iridescenceThicknessWrapS',missing,@(x)GLTF.validateString(x,wrap_str_values));
    ips.addParameter('iridescenceThicknessWrapT',missing,@(x)GLTF.validateString(x,wrap_str_values));
    ips.addParameter('iridescenceThicknessEmbedTexture',true,@islogical);
    ips.parse(varargin{:});
    parameters=ips.Results;
    name=parameters.name;
    metallicFactor=parameters.metallicFactor;
    roughnessFactor=parameters.roughnessFactor;
    doubleSided=parameters.doubleSided;
    alphaMode=upper(parameters.alphaMode);
    baseColorFactor=parameters.baseColorFactor;
    baseColorTexture=parameters.baseColorTexture;
    baseColorTextureSet=parameters.baseColorTextureSet;
    baseColorMagFilter=upper(parameters.baseColorMagFilter);
    baseColorMinFilter=upper(parameters.baseColorMinFilter);
    baseColorWrapS=upper(parameters.baseColorWrapS);
    baseColorWrapT=upper(parameters.baseColorWrapT);
    baseColorEmbedTexture=parameters.baseColorEmbedTexture;
    normalTexture=parameters.normalTexture;
    normalTextureSet=parameters.normalTextureSet;
    normalMagFilter=upper(parameters.normalMagFilter);
    normalMinFilter=upper(parameters.normalMinFilter);
    normalWrapS=upper(parameters.normalWrapS);
    normalWrapT=upper(parameters.normalWrapT);
    normalEmbedTexture=parameters.normalEmbedTexture;
    occlusionTexture=parameters.occlusionTexture;
    occlusionTextureSet=parameters.occlusionTextureSet;
    occlusionMagFilter=upper(parameters.occlusionMagFilter);
    occlusionMinFilter=upper(parameters.occlusionMinFilter);
    occlusionWrapS=upper(parameters.occlusionWrapS);
    occlusionWrapT=upper(parameters.occlusionWrapT);
    occlusionEmbedTexture=parameters.occlusionEmbedTexture;
    emissiveFactor=parameters.emissiveFactor;
    emissiveTexture=parameters.emissiveTexture;
    emissiveTextureSet=parameters.emissiveTextureSet;
    emissiveMagFilter=upper(parameters.emissiveMagFilter);
    emissiveMinFilter=upper(parameters.emissiveMinFilter);
    emissiveWrapS=upper(parameters.emissiveWrapS);
    emissiveWrapT=upper(parameters.emissiveWrapS);
    emissiveEmbedTexture=parameters.emissiveEmbedTexture;
    emissiveStrength=parameters.emissiveStrength;
    transmissionFactor=parameters.transmissionFactor;
    transmissionTexture=parameters.transmissionTexture;
    transmissionTextureSet=parameters.transmissionTextureSet;
    transmissionMagFilter=upper(parameters.transmissionMagFilter);
    transmissionMinFilter=upper(parameters.transmissionMinFilter);
    transmissionWrapS=upper(parameters.transmissionWrapS);
    transmissionWrapT=upper(parameters.transmissionWrapT);
    transmissionEmbedTexture=parameters.transmissionEmbedTexture;
    ior=parameters.ior;
    thicknessFactor=parameters.thicknessFactor;
    thicknessTexture=parameters.thicknessTexture;
    thicknessTextureSet=parameters.thicknessTextureSet;
    thicknessMagFilter=upper(parameters.thicknessMagFilter);
    thicknessMinFilter=upper(parameters.thicknessMinFilter);
    thicknessWrapS=upper(parameters.thicknessWrapS);
    thicknessWrapT=upper(parameters.thicknessWrapT);
    thicknessEmbedTexture=parameters.thicknessEmbedTexture;
    attenuationDistance=parameters.attenuationDistance;
    attenuationColor=parameters.attenuationColor;
    clearcoatFactor=parameters.clearcoatFactor;
    clearcoatTexture=parameters.clearcoatTexture;
    clearcoatTextureSet=parameters.clearcoatTextureSet;
    clearcoatMagFilter=upper(parameters.clearcoatMagFilter);
    clearcoatMinFilter=upper(parameters.clearcoatMinFilter);
    clearcoatWrapS=upper(parameters.clearcoatWrapS);
    clearcoatWrapT=upper(parameters.clearcoatWrapT);
    clearcoatEmbedTexture=parameters.clearcoatEmbedTexture;
    clearcoatRoughnessFactor=parameters.clearcoatRoughnessFactor;
    clearcoatRoughnessTexture=parameters.clearcoatRoughnessTexture;
    clearcoatRoughnessTextureSet=parameters.clearcoatRoughnessTextureSet;
    clearcoatRoughnessMagFilter=upper(parameters.clearcoatRoughnessMagFilter);
    clearcoatRoughnessMinFilter=upper(parameters.clearcoatRoughnessMinFilter);
    clearcoatRoughnessWrapS=upper(parameters.clearcoatRoughnessWrapS);
    clearcoatRoughnessWrapT=upper(parameters.clearcoatRoughnessWrapT);
    clearcoatRoughnessEmbedTexture=parameters.clearcoatRoughnessEmbedTexture;
    clearcoatNormalTexture=parameters.clearcoatNormalTexture;
    clearcoatNormalTextureSet=parameters.clearcoatNormalTextureSet;
    clearcoatNormalMagFilter=upper(parameters.clearcoatNormalMagFilter);
    clearcoatNormalMinFilter=upper(parameters.clearcoatNormalMinFilter);
    clearcoatNormalWrapS=upper(parameters.clearcoatNormalWrapS);
    clearcoatNormalWrapT=upper(parameters.clearcoatNormalWrapT);
    clearcoatNormalEmbedTexture=parameters.clearcoatNormalEmbedTexture;
    sheenColorFactor=parameters.sheenColorFactor;
    sheenColorTexture=parameters.sheenColorTexture;
    sheenColorTextureSet=parameters.sheenColorTextureSet;
    sheenColorMagFilter=upper(parameters.sheenColorMagFilter);
    sheenColorMinFilter=upper(parameters.sheenColorMinFilter);
    sheenColorWrapS=upper(parameters.sheenColorWrapS);
    sheenColorWrapT=upper(parameters.sheenColorWrapT);
    sheenColorEmbedTexture=parameters.sheenColorEmbedTexture;
    sheenRoughnessFactor=parameters.sheenRoughnessFactor;
    sheenRoughnessTexture=parameters.sheenRoughnessTexture;
    sheenRoughnessTextureSet=parameters.sheenRoughnessTextureSet;
    sheenRoughnessMagFilter=upper(parameters.sheenRoughnessMagFilter);
    sheenRoughnessMinFilter=upper(parameters.sheenRoughnessMinFilter);
    sheenRoughnessWrapS=upper(parameters.sheenRoughnessWrapS);
    sheenRoughnessWrapT=upper(parameters.sheenRoughnessWrapT);
    sheenRoughnessEmbedTexture=parameters.sheenRoughnessEmbedTexture;
    specularFactor=parameters.specularFactor;
    specularTexture=parameters.specularTexture;
    specularTextureSet=parameters.specularTextureSet;
    specularMagFilter=upper(parameters.specularMagFilter);
    specularMinFilter=upper(parameters.specularMinFilter);
    specularWrapS=upper(parameters.specularWrapS);
    specularWrapT=upper(parameters.specularWrapT);
    specularEmbedTexture=parameters.specularEmbedTexture;
    specularColorFactor=parameters.specularColorFactor;
    specularColorTexture=parameters.specularColorTexture;
    specularColorTextureSet=parameters.specularColorTextureSet;
    specularColorMagFilter=upper(parameters.specularColorMagFilter);
    specularColorMinFilter=upper(parameters.specularColorMinFilter);
    specularColorWrapS=upper(parameters.specularColorWrapS);
    specularColorWrapT=upper(parameters.specularColorWrapT);
    specularColorEmbedTexture=parameters.specularColorEmbedTexture;
    iridescenceFactor=parameters.iridescenceFactor;
    iridescenceTexture=parameters.iridescenceTexture;
    iridescenceTextureSet=parameters.iridescenceTextureSet;
    iridescenceIor=parameters.iridescenceIor;
    iridescenceThicknessMinimum=parameters.iridescenceThicknessMinimum;
    iridescenceThicknessMaximum=parameters.iridescenceThicknessMaximum;
    iridescenceMagFilter=upper(parameters.iridescenceMagFilter);
    iridescenceMinFilter=upper(parameters.iridescenceMinFilter);
    iridescenceWrapS=upper(parameters.iridescenceWrapS);
    iridescenceWrapT=upper(parameters.iridescenceWrapT);
    iridescenceEmbedTexture=parameters.iridescenceEmbedTexture;
    iridescenceThicknessTexture=parameters.iridescenceThicknessTexture;
    iridescenceThicknessTextureSet=parameters.iridescenceThicknessTextureSet;
    iridescenceThicknessMagFilter=upper(parameters.iridescenceThicknessMagFilter);
    iridescenceThicknessMinFilter=upper(parameters.iridescenceThicknessMinFilter);
    iridescenceThicknessWrapS=upper(parameters.iridescenceThicknessWrapS);
    iridescenceThicknessWrapT=upper(parameters.iridescenceThicknessWrapT);
    iridescenceThicknessEmbedTexture=parameters.iridescenceThicknessEmbedTexture;
    unlit=parameters.unlit;
    material=struct();
    if(~isempty(baseColorFactor))
        if(numel(baseColorFactor)<4)
            baseColorFactor=[baseColorFactor 1];
        end
        if(ismissing(alphaMode))
            if(size(baseColorFactor,2)==3)
                alphaMode="OPAQUE";
            elseif(size(baseColorFactor,2)==4)
                if(baseColorFactor(4)<1)
                    alphaMode="BLEND";
                else
                    alphaMode="OPAQUE";
                end
            end
        end
        material.pbrMetallicRoughness.baseColorFactor=baseColorFactor;
    end
    if(and(alphaMode~="OPAQUE",~ismissing(alphaMode)))
        material.alphaMode=alphaMode;
    end
    if(~isempty(doubleSided))
        material.doubleSided=doubleSided;
    end
    if(~isempty(metallicFactor))
        material.pbrMetallicRoughness.metallicFactor=metallicFactor;
    end
    if(~isempty(roughnessFactor))
        material.pbrMetallicRoughness.roughnessFactor=roughnessFactor;
    end
    if(~ismissing(name))
        material.name=name;
    end
    if(~ismissing(baseColorTexture))
        material.pbrMetallicRoughness.baseColorTexture=struct('index',addTexture(gltf,baseColorTexture,'magFilter',baseColorMagFilter,'minFilter',baseColorMinFilter,'wrapS',baseColorWrapS,'wrapT',baseColorWrapT,'embedTexture',baseColorEmbedTexture));
    end
    if(~isnan(baseColorTextureSet))
        material.pbrMetallicRoughness.baseColorTexture.texCoord=baseColorTextureSet;
    end
    if(~ismissing(normalTexture))
        material.normalTexture=struct('index',addTexture(gltf,normalTexture,'magFilter',normalMagFilter,'minFilter',normalMinFilter,'wrapS',normalWrapS,'wrapT',normalWrapT,'embedTexture',normalEmbedTexture));
    end
    if(~isnan(normalTextureSet))
        material.normalTexture.texCoord=normalTextureSet;
    end
    if(~ismissing(occlusionTexture))
        material.occlusionTexture=struct('index',addTexture(gltf,occlusionTexture,'magFilter',occlusionMagFilter,'minFilter',occlusionMinFilter,'wrapS',occlusionWrapS,'wrapT',occlusionWrapT,'embedTexture',occlusionEmbedTexture));
    end
    if(~isnan(occlusionTextureSet))
        material.occlusionTexture.texCoord=occlusionTextureSet;
    end
    if(~ismissing(emissiveTexture))
        material.emissiveTexture=struct('index',addTexture(gltf,emissiveTexture,'magFilter',emissiveMagFilter,'minFilter',emissiveMinFilter,'wrapS',emissiveWrapS,'wrapT',emissiveWrapT,'embedTexture',emissiveEmbedTexture));
    end
    if(~isnan(emissiveTextureSet))
        material.emissiveTexture.texCoord=emissiveTextureSet;
    end
    if(~isempty(emissiveFactor))
        material.emissiveFactor=emissiveFactor;
    end
    if(~ismember("emissiveStrength",ips.UsingDefaults))
        addExtension(gltf,"KHR_materials_emissive_strength");
        if(~isempty(emissiveStrength))
            iorstruct=struct('emissiveStrength',emissiveStrength);
        else
            iorstruct=struct();
        end
        material.extensions.KHR_materials_ior=struct('KHR_materials_emissive_strength',iorstruct);
    end
    if(or(~isempty(transmissionFactor),~ismissing(transmissionTexture)))
        addExtension(gltf,"KHR_materials_transmission");
        KHR_materials_transmission_struct=struct();
        if(~isempty(transmissionFactor))
            KHR_materials_transmission_struct.transmissionFactor=transmissionFactor;
        end
        if(~ismissing(transmissionTexture))
            KHR_materials_transmission_struct.transmissionTexture=struct('index',addTexture(gltf,transmissionTexture,'magFilter',transmissionMagFilter,'minFilter',transmissionMinFilter,'wrapS',transmissionWrapS,'wrapT',transmissionWrapT,'embedTexture',transmissionEmbedTexture));
        end
        if(~isnan(transmissionTextureSet))
            KHR_materials_transmission_struct.transmissionTexture.texCoord=transmissionTextureSet;
        end
        material.extensions.KHR_materials_transmission=KHR_materials_transmission_struct;
    end
    if(~ismember("ior",ips.UsingDefaults))
        addExtension(gltf,"KHR_materials_ior");
        if(~isempty(ior))
            iorstruct=struct('ior',ior);
        else
            iorstruct=struct();
        end
        material.extensions.KHR_materials_ior=struct('KHR_materials_ior',iorstruct);
    end
    if(or(or(~isempty(thicknessFactor),~ismissing(thicknessTexture)),or(~isempty(attenuationDistance),~isempty(attenuationColor))))
        addExtension(gltf,"KHR_materials_transmission");
        addExtension(gltf,"KHR_materials_volume");
        KHR_materials_volume_struct=struct();
        if(~isempty(thicknessFactor))
            KHR_materials_volume_struct.thicknessFactor=thicknessFactor;
        end
        if(~ismissing(thicknessTexture))
            KHR_materials_volume_struct.thicknessTexture=struct('index',addTexture(gltf,thicknessTexture,'magFilter',thicknessMagFilter,'minFilter',thicknessMinFilter,'wrapS',thicknessWrapS,'wrapT',thicknessWrapT,'embedTexture',thicknessEmbedTexture));
        end
        if(~isnan(thicknessTextureSet))
            KHR_materials_volume_struct.thicknessTexture.texCoord=thicknessTextureSet;
        end
        if(~isempty(attenuationDistance))
            KHR_materials_volume_struct.attenuationDistance=attenuationDistance;
        end
        if(~isempty(attenuationColor))
            KHR_materials_volume_struct.attenuationColor=attenuationColor;
        end
        material.extensions.KHR_materials_volume=KHR_materials_volume_struct;
    end
    if(or(or(~isempty(clearcoatFactor),~ismissing(clearcoatTexture)),or(~isempty(clearcoatRoughnessFactor),or(~ismissing(clearcoatRoughnessTexture),~ismissing(clearcoatNormalTexture)))))
        addExtension(gltf,"KHR_materials_clearcoat");
        KHR_materials_clearcoat_struct=struct();
        if(~isempty(clearcoatFactor))
            KHR_materials_clearcoat_struct.clearcoatFactor=clearcoatFactor;
        end
        if(~ismissing(clearcoatTexture))
            KHR_materials_clearcoat_struct.clearcoatTexture=struct('index',addTexture(gltf,clearcoatTexture,'magFilter',clearcoatMagFilter,'minFilter',clearcoatMinFilter,'wrapS',clearcoatWrapS,'wrapT',clearcoatWrapT,'embedTexture',clearcoatEmbedTexture));
        end
        if(~isnan(clearcoatTextureSet))
            KHR_materials_clearcoat_struct.clearcoatTexture.texCoord=clearcoatTextureSet;
        end
        if(~isempty(clearcoatRoughnessFactor))
            KHR_materials_clearcoat_struct.clearcoatRoughnessFactor=clearcoatRoughnessFactor;
        end
        if(~ismissing(clearcoatRoughnessTexture))
            KHR_materials_clearcoat_struct.clearcoatRoughnessTexture=struct('index',addTexture(gltf,clearcoatRoughnessTexture,'magFilter',clearcoatRoughnessMagFilter,'minFilter',clearcoatRoughnessMinFilter,'wrapS',clearcoatRoughnessWrapS,'wrapT',clearcoatRoughnessWrapT,'embedTexture',clearcoatRoughnessEmbedTexture));
        end
        if(~isnan(clearcoatRoughnessTextureSet))
            KHR_materials_clearcoat_struct.clearcoatRoughnessTexture.texCoord=clearcoatRoughnessTextureSet;
        end
        if(~ismissing(clearcoatNormalTexture))
            KHR_materials_clearcoat_struct.clearcoatNormalTexture=struct('index',addTexture(gltf,clearcoatNormalTexture,'magFilter',clearcoatNormalMagFilter,'minFilter',clearcoatNormalMinFilter,'wrapS',clearcoatNormalWrapS,'wrapT',clearcoatNormalWrapT,'embedTexture',clearcoatNormalEmbedTexture));
        end
        if(~isnan(clearcoatNormalTextureSet))
            KHR_materials_clearcoat_struct.clearcoatNormalTexture.texCoord=clearcoatNormalTextureSet;
        end
        material.extensions.KHR_materials_clearcoat=KHR_materials_clearcoat_struct;
    end
    if(or(or(~isempty(sheenColorFactor),~ismissing(sheenColorTexture)),or(~isempty(sheenRoughnessFactor),~ismissing(sheenRoughnessTexture))))
        addExtension(gltf,"KHR_materials_sheen");
        KHR_materials_sheen_struct=struct();
        if(~isempty(sheenColorFactor))
            KHR_materials_sheen_struct.sheenColorFactor=sheenColorFactor;
        end
        if(~ismissing(sheenColorTexture))
            KHR_materials_sheen_struct.sheenColorTexture=struct('index',addTexture(gltf,sheenColorTexture,'magFilter',sheenColorMagFilter,'minFilter',sheenColorMinFilter,'wrapS',sheenColorWrapS,'wrapT',sheenColorWrapT,'embedTexture',sheenColorEmbedTexture));
        end
        if(~isnan(sheenColorTextureSet))
            KHR_materials_sheen_struct.sheenColorTexture.texCoord=sheenColorTextureSet;
        end
        if(~isempty(sheenRoughnessFactor))
            KHR_materials_sheen_struct.sheenRoughnessFactor=sheenRoughnessFactor;
        end
        if(~ismissing(sheenRoughnessTexture))
            KHR_materials_sheen_struct.sheenRoughnessTexture=struct('index',addTexture(gltf,sheenRoughnessTexture,'magFilter',sheenRoughnessMagFilter,'minFilter',sheenRoughnessMinFilter,'wrapS',sheenRoughnessWrapS,'wrapT',sheenRoughnessWrapT,'embedTexture',sheenRoughnessEmbedTexture));
        end
        if(~isnan(sheenRoughnessTextureSet))
            KHR_materials_sheen_struct.sheenRoughnessTexture.texCoord=sheenRoughnessTextureSet;
        end
        material.extensions.KHR_materials_sheen=KHR_materials_sheen_struct;
    end
    if(or(or(~isempty(specularFactor),~ismissing(specularTexture)),or(~isempty(specularColorFactor),~ismissing(specularColorTexture))))
        addExtension(gltf,"KHR_materials_specular");
        KHR_materials_specular_struct=struct();
        if(~isempty(specularFactor))
            KHR_materials_specular_struct.specularFactor=specularFactor;
        end
        if(~ismissing(specularTexture))
            KHR_materials_specular_struct.specularTexture=struct('index',addTexture(gltf,specularTexture,'magFilter',specularMagFilter,'minFilter',specularMinFilter,'wrapS',specularWrapS,'wrapT',specularWrapT,'embedTexture',specularEmbedTexture));
        end
        if(~isnan(specularTextureSet))
            KHR_materials_specular_struct.specularTexture.texCoord=specularTextureSet;
        end
        if(~isempty(specularColorFactor))
            KHR_materials_specular_struct.specularColorFactor=specularColorFactor;
        end
        if(~ismissing(specularColorTexture))
            KHR_materials_specular_struct.specularColorTexture=struct('index',addTexture(gltf,specularColorTexture,'magFilter',specularColorMagFilter,'minFilter',specularColorMinFilter,'wrapS',specularColorWrapS,'wrapT',specularColorWrapT,'embedTexture',specularColorEmbedTexture));
        end
        if(~isnan(specularColorTextureSet))
            KHR_materials_specular_struct.specularColorTexture.texCoord=specularColorTextureSet;
        end
        material.extensions.KHR_materials_specular=KHR_materials_specular_struct;
    end
    if(unlit)
        addExtension(gltf,"KHR_materials_unlit");
        material.extensions.KHR_materials_unlit=struct;
    end
    if(or(or(~isempty(iridescenceFactor),~ismissing(iridescenceTexture)),or(or(~isempty(iridescenceThicknessMinimum),~isempty(iridescenceThicknessMaximum)),~ismissing(iridescenceThicknessTexture))))
        addExtension(gltf,"KHR_materials_iridescence");
        KHR_materials_iridescence_struct=struct();
        if(~isempty(iridescenceFactor))
	        KHR_materials_iridescence_struct.iridescenceFactor=iridescenceFactor;
        end
        if(~ismissing(iridescenceTexture))
	        KHR_materials_iridescence_struct.iridescenceTexture=struct('index',addTexture(gltf,iridescenceTexture,'magFilter',iridescenceMagFilter,'minFilter',iridescenceMinFilter,'wrapS',iridescenceWrapS,'wrapT',iridescenceWrapT,'embedTexture',iridescenceEmbedTexture));
        end
        if(~isnan(iridescenceTextureSet))
	        KHR_materials_iridescence_struct.iridescenceTexture.texCoord=iridescenceTextureSet;
        end
        if(~isempty(iridescenceIor))
	        KHR_materials_iridescence_struct.iridescenceIor=iridescenceIor;
        end 
        if(~isempty(iridescenceThicknessMinimum))
	        KHR_materials_iridescence_struct.iridescenceThicknessMinimum=iridescenceThicknessMinimum;
        end
        if(~isempty(iridescenceThicknessMaximum))
	        KHR_materials_iridescence_struct.iridescenceThicknessMaximum=iridescenceThicknessMaximum;
        end
        if(~ismissing(iridescenceThicknessTexture))
	        KHR_materials_iridescence_struct.iridescenceThicknessTexture=struct('index',addTexture(gltf,iridescenceThicknessTexture,'magFilter',iridescenceThicknessMagFilter,'minFilter',iridescenceThicknessMinFilter,'wrapS',iridescenceThicknessWrapS,'wrapT',iridescenceThicknessWrapT,'embedTexture',iridescenceThicknessEmbedTexture));
        end
        if(~isnan(iridescenceThicknessTextureSet))
	        KHR_materials_iridescence_struct.iridescenceThicknessTexture.texCoord=iridescenceThicknessTextureSet;
        end
        material.extensions.KHR_materials_iridescence=KHR_materials_iridescence_struct;
    end
    if(~isprop(gltf,'materials'))
        gltf.addprop('materials');
    end
    material_idx=numel(gltf.materials);
    gltf.materials=[gltf.materials {material}];
end
