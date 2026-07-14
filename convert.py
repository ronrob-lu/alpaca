import trimesh

mesh = trimesh.load('lmgjam_notloc_alpac_alachia/models/notloc_alpaca.glb', force='mesh')
mesh.apply_scale(0.1)
mesh.export('models/notloc_alpaca.obj')
