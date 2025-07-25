[Mesh]
  type = GeneratedMesh # Can generate simple lines, rectangles and rectangular prisms
  dim = 2 # Dimension of the mesh
  nx = 100 # Number of elements in the x direction
  ny = 10 # Number of elements in the y direction
  xmax = 0.304 # Length of test chamber
  ymax = 0.0257 # Test chamber radius
[]

[Problem]
  type = FEProblem # This is the "normal" type of Finite Element Problem in MOOSE
  coord_type = RZ # Axisymmetric RZ
  rz_coord_axis = X # Which axis the symmetry is around
[]

[Variables]
  [pressure]
    # Adds a Linear Lagrange variable by default
  []
[]

[Kernels]
  [diffusion]
    type = DarcyPressure # Zero-gravity, divergence-free form of Darcy's law
    variable = pressure # Operate on the "pressure" variable from above
  []
[]

[AuxVariables]
  [velocity]
    order = CONSTANT # Since "pressure" is approximated linearly, its gradient must be constant
    family = MONOMIAL_VEC # A monomial interpolation means this is an elemental AuxVariable
  []
[]

[AuxKernels]
    [velocity]
    type = DarcyVelocity
    variable = velocity # Store volumetric flux vector in "velocity" variable from above
    pressure = pressure # Couple to the "pressure" variable from above
    execute_on = TIMESTEP_END # Perform calculation at the end of the solve step - after Kernels run
  []
[]

[Materials]
  [filter]
    type = PackedColumn # Provides permeability and viscosity of water through packed 1mm spheres
  []
[]

[BCs]
  [inlet]
    type = ADDirichletBC # Simple u=value BC
    variable = pressure # Variable to be set
    boundary = left # Name of a sideset in the mesh
    value = 4000 # (Pa) From Figure 2 from paper. First data point for 1mm spheres.
  []
  [outlet]
    type = ADDirichletBC
    variable = pressure
    boundary = right
    value = 0 # (Pa) Gives the correct pressure drop from Figure 2 for 1mm spheres
  []
[]

[Executioner]
  type = Steady # Steady state problem
  solve_type = NEWTON # Perform a Newton solve

  # Set PETSc parameters to optimize solver efficiency
  petsc_options_iname = '-pc_type -pc_hypre_type' # PETSc option pairs with values below
  petsc_options_value = ' hypre    boomeramg'
[]

[Outputs]
  exodus = true # Output Exodus format
[]
