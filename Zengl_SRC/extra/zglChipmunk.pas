{----------------------------------------------}
{-----------------= Chipmunk =-----------------}
{----------------------------------------------}
{                                              }
{ author:   Scott Lembcke                      }
{ mail:     slembcke@gmail.com                 }
{                                              }
{ version:  5.3.2                              }
{ license:  MIT                                }
{ homepage: http://chipmunk-physics.net/       }
{                                              }
{------------------- header -------------------}
{                                              }
{ version:  1.0.1                              }
{ date:     2013.03.31                         }
{                                              }
{------------- header written by: -------------}
{                                              }
{           Kemka Andrey aka Andru             }
{                                              }
{ e-mail: dr.andru@gmail.com                   }
{ jabber: dr.andru@googlemail.com              }
{ icq:    496929849                            }
{ skype:  andru-kun                            }
{                                              }
{----------------------------------------------}
// modification by Serge 24.02.2022
unit zglChipmunk;

{$I zglCustomConfig.cfg}
{$I zgl_config.cfg}

{$IFDEF FPC}
  {.$MODE DELPHI}
  {$PACKRECORDS C}
  {$MINENUMSIZE 4}
  {$IfNDef ANDROID}                // костыль...
  {$IFDEF USE_CHIPMUNK_STATIC}
    {$L chipmunk}
    {$L cpArbiter}
    {$L cpArray}
    {$L cpBB}
    {$L cpBody}
    {$L cpCollision}
    {$L cpConstraint}
    {$L cpDampedRotarySpring}
    {$L cpDampedSpring}
    {$L cpGearJoint}
    {$L cpGrooveJoint}
    {$L cpHashSet}
    {$L cpPinJoint}
    {$L cpPivotJoint}
    {$L cpPolyShape}
    {$L cpRatchetJoint}
    {$L cpRotaryLimitJoint}
    {$L cpShape}
    {$L cpSimpleMotor}
    {$L cpSlideJoint}
    {$L cpSpace}
    {$L cpSpaceComponent}
    {$L cpSpaceHash}
    {$L cpSpaceQuery}
    {$L cpSpaceStep}
    {$L cpVect}
    {$IF DEFINED(iOS) and (not DEFINED(iPHONESIM))}
      {$LINKLIB libgcc_s.1.dylib}
    {$IFEND}
    {$IFDEF WINDOWS}
      {$LINKLIB libmsvcrt.a}
    {$ENDIF}
  {$ENDIF}
  {$EndIf}
{$ENDIF}

interface
uses
  {$IFDEF MACOSX}
  MacOSAll,
  {$ENDIF}
  zgl_types,
  {$IfNDef OLD_METHODS}
  gegl_color,
  {$EndIf}
  zgl_primitives_2d;


const
{$IFDEF LINUX}
  libChipmunk = 'libchipmunk.so.5.3.2';
{$ENDIF}
{$IFDEF ANDROID}
  libChipmunk = 'libchipmunk.so';
{$ENDIF}
{$IFDEF WINDOWS}
  libChipmunk = 'chipmunk.dll';
{$ENDIF}
{$IFDEF MACOSX}
  libChipmunk = 'libchipmunk.5.3.2.dylib';
{$ENDIF}

// компиляция врутри???
{$IF ( not DEFINED( USE_CHIPMUNK_STATIC ) ) and ( not DEFINED( USE_CHIPMUNK_LINK ) )}
function  cpLoad( LibraryName : AnsiString; Error : Boolean = TRUE ) : Boolean;
procedure cpFree;
{$IFEND}

type
  cpHashValue     = LongWord;
  cpBool          = LongBool;
  cpFloat         = {$IF DEFINED(iOS) or DEFINED(ANDROID)} Single {$ELSE} Double {$IFEND};
  cpDataPointer   = Pointer;
  cpCollisionType = LongWord;
  cpGroup         = LongWord;
  cpLayers        = LongWord;
  cpTimestamp     = LongWord;

// FORWARD DECLARATIONS
type
  PcpBB = ^cpBB;
// ARRAY
  PcpArray = ^cpArray;
// ARBITER
  PcpContact = ^cpContact;
  PcpArbiter = ^cpArbiter;
// SHAPE
  PcpShapeClass = ^cpShapeClass;
  PPcpShape = ^PcpShape;
  PcpShape = ^cpShape;
// CIRCLESHAPE
  PcpCircleShape = ^cpCircleShape;
// SEGMENTSHAPE
  PcpSegmentQueryInfo = ^cpSegmentQueryInfo;
  PcpSegmentShape = ^cpSegmentShape;
// POLYSHAPE
  PcpPolyShapeAxis = ^cpPolyShapeAxis;
  PcpPolyShape = ^cpPolyShape;
// BODY
  PcpComponentNode = ^cpComponentNode;
  PPcpBody = ^PcpBody;
  PcpBody = ^cpBody;
// CONSTRAINTS
  PcpConstraintClass = ^cpConstraintClass;
  PcpConstraint = ^cpConstraint;
  PcpPinJoint = ^cpPinJoint;
  PcpSlideJoint = ^cpSlideJoint;
  PcpPivotJoint = ^cpPivotJoint;
  PcpGrooveJoint = ^cpGrooveJoint;
  PcpDampedSpring = ^cpDampedSpring;
  PcpDampedRotarySpring = ^cpDampedRotarySpring;
  PcpRotaryLimitJoint = ^cpRotaryLimitJoint;
  PcpRatchetJoint = ^cpRatchetJoint;
  PcpGearJoint = ^cpGearJoint;
  PcpSimpleMotor = ^cpSimpleMotor;
// SPACE
  PcpCollisionHandler = ^cpCollisionHandler;
  PcpContactBufferHeader = ^cpContactBufferHeader;
  PcpSpace = ^cpSpace;
// HASHSET
  PPcpHashSetBin = ^PcpHashSetBin;
  PcpHashSetBin = ^cpHashSetBin;
  PcpHashSet = ^cpHashSet;
// SPACEHASH
  PcpHandle = ^cpHandle;
  PPcpSpaceHashBin = ^PcpSpaceHashBin;
  PcpSpaceHashBin = ^cpSpaceHashBin;
  PcpSpaceHash = ^cpSpaceHash;

// VECT
  PcpVect = ^cpVect;
  cpVect  = record
    x : cpFloat;
    y : cpFloat;
  end;

  cpVectArrayHack = array[ 0..High(LongWord) div 32 - 1 ] of cpVect;
  cpVectArray     = ^cpVectArrayHack;

// BB
  cpBB = record
    l, b, r, t : cpFloat;
  end;

// ARRAY
  // NOTE: cpArray is rarely used and will probably go away.
  cpArray = record
    num, max : Integer;
    arr : ^Pointer;
  end;

  cpArrayIter = procedure( ptr : Pointer; data : Pointer ); cdecl;

// ARBITER
  // Data structure for contact points.
  cpContact = record
    // Contact point and normal.
    p, n : cpVect;
    // Penetration distance.
    dist : cpFloat;

    // Calculated by cpArbiterPreStep().
    r1, r2 : cpVect;
    nMass, tMass, bounce : cpFloat;

    // Persistant contact information.
    jnAcc, jtAcc, jBias : cpFloat;
    bias : cpFloat;

    // Hash value used to (mostly) uniquely identify a contact.
    hash : cpHashValue;
  end;

  cpContactArrayHack = array[ 0..High(LongWord) div ( SizeOf( cpContact ) * 2 ) - 1 ] of cpContact;
  cpContactArray     = ^cpContactArrayHack;

  cpArbiterState = ( cpArbiterStateNormal, cpArbiterStateFirstColl, cpArbiterStateIgnore, cpArbiterStateSleep, cpArbiterStateCached );

  // Data structure for tracking collisions between shapes.
  cpArbiter = record
    // Information on the contact points between the objects.
    numContacts : Integer;
    contacts : cpContactArray;

    // The two shapes and bodies involved in the collision.
    // These variables are NOT in the order defined by the collision handler.
    // Using CP_ARBITER_GET_SHAPES and CP_ARBITER_GET_BODIES will save you from
    // many headaches
    private_a, private_b : PcpShape;

    // Calculated before calling the pre-solve collision handler
    // Override them with custom values if you want specialized behavior
    e : cpFloat;
    u : cpFloat;
    // Used for surface_v calculations, implementation may change
    surface_vr : cpVect;

    // Time stamp of the arbiter. (from cpSpace)
    stamp : cpTimestamp;

    handler : PcpCollisionHandler;

    // Are the shapes swapped in relation to the collision handler?
    swappedColl : cpBool;
    state : cpArbiterState;
  end;

// SHAPE
  cpSegmentQueryInfo = record
    shape : PcpShape; // shape that was hit, NULL if no collision
    t : cpFloat; // Distance along query segment, will always be in the range [0, 1].
    n : cpVect; // normal of hit surface
  end;

  // Enumeration of shape types.
  cpShapeType = ( CP_CIRCLE_SHAPE, CP_SEGMENT_SHAPE, CP_POLY_SHAPE, CP_NUM_SHAPES );

  cpShapeClass = record
    _type : cpShapeType;

    // Called by cpShapeCacheBB().
    cacheData : function( shape : PcpShape; p : cpVect; rot : cpVect ) : cpBB; cdecl;
    // Called to by cpShapeDestroy().
    destroy : procedure( shape : PcpShape ); cdecl;

    // called by cpShapePointQuery().
    pointQuery : function( shape : PcpShape; p : cpVect ) : cpBool; cdecl;

    // called by cpShapeSegmentQuery()
    segmentQuery : procedure( shape : PcpShape; a : cpVect; b : cpVect; info : PcpSegmentQueryInfo ); cdecl;
  end;

  // Basic shape struct that the others inherit from.
  cpShape = record
    // The "class" of a shape as defined above
    klass : PcpShapeClass;

    // cpBody that the shape is attached to.
    body : PcpBody;

    // Cached BBox for the shape.
    bb : cpBB;

    // Sensors invoke callbacks, but do not generate collisions
    sensor : cpBool;

    // *** Surface properties.

    // Coefficient of restitution. (elasticity)
    e : cpFloat;
    // Coefficient of friction.
    u : cpFloat;
    // Surface velocity used when solving for friction.
    surface_v : cpVect;

    // *** User Definable Fields

    // User defined data pointer for the shape.
    data : cpDataPointer;

    // User defined collision type for the shape.
    collision_type : cpCollisionType;
    // User defined collision group for the shape.
    group : cpGroup;
    // User defined layer bitmask for the shape.
    layers : cpLayers;

    // *** Internally Used Fields

    // Shapes form a linked list when added to space on a non-NULL body
    next : PcpShape;

    // Unique id used as the hash value.
    hashid : cpHashValue;
  end;

// CIRCLESHAPE
  cpCircleShape = record
    shape : cpShape;

    // Center in body space coordinates
    c : cpVect;
    // Radius.
    r : cpFloat;

    // Transformed center. (world space coordinates)
    tc : cpVect;
  end;

// SEGMENTSHAPE
  // Segment shape structure.
  cpSegmentShape = record
    shape : cpShape;

    // Endpoints and normal of the segment. (body space coordinates)
    a, b, n : cpVect;
    // Radius of the segment. (Thickness)
    r : cpFloat;

    // Transformed endpoints and normal. (world space coordinates)
    ta, tb, tn : cpVect;
  end;

// POLYSHAPE
  // Axis structure used by cpPolyShape.
  cpPolyShapeAxis = record
    // normal
    n : cpVect;
    // distance from origin
    d : cpFloat;
  end;

  cpPolyShapeAxisArrayHack = array[ 0..High(LongWord) div 48 - 1 ] of cpPolyShapeAxis;
  cpPolyShapeAxisArray     = ^cpPolyShapeAxisArrayHack;

  // Convex polygon shape structure.
  cpPolyShape = record
    shape : cpShape;

    // Vertex and axis lists.
    numVerts : Integer;
    verts : cpVectArray;
    axes : cpPolyShapeAxisArray;

    // Transformed vertex and axis lists.
    tVerts : cpVectArray;
    tAxes : cpPolyShapeAxisArray;
  end;

// BODY
  cpBodyVelocityFunc = procedure( body : PcpBody; gravity : cpVect; damping : cpFloat; dt : cpFloat ); cdecl;
  cpBodyPositionFunc = procedure( body : PcpBody; dt : cpFloat ); cdecl;

  cpComponentNode = record
    parent : PcpBody;
    next : PcpBody;
    rank : Integer;
    idleTime : cpFloat;
  end;

  cpBody = record
    // *** Integration Functions.

    // Function that is called to integrate the body's velocity. (Defaults to cpBodyUpdateVelocity)
    velocity_func : cpBodyVelocityFunc;

    // Function that is called to integrate the body's position. (Defaults to cpBodyUpdatePosition)
    position_func : cpBodyPositionFunc;

    // *** Mass Properties

    // Mass and it's inverse.
    // Always use cpBodySetMass() whenever changing the mass as these values must agree.
    m, m_inv : cpFloat;

    // Moment of inertia and it's inverse.
    // Always use cpBodySetMoment() whenever changing the moment as these values must agree.
    i, i_inv : cpFloat;

    // *** Positional Properties

    // Linear components of motion (position, velocity, and force)
    p, v, f : cpVect;

    // Angular components of motion (angle, angular velocity, and torque)
    // Always use cpBodySetAngle() to set the angle of the body as a and rot must agree.
    a, w, t : cpFloat;

    // Cached unit length vector representing the angle of the body.
    // Used for fast vector rotation using cpvrotate().
    rot : cpVect;

    // *** User Definable Fields

    // User defined data pointer.
    data : cpDataPointer;

    // *** Other Fields

    // Maximum velocities this body can move at after integrating velocity
    v_limit, w_limit : cpFloat;

    // *** Internally Used Fields

    // Velocity bias values used when solving penetrations and correcting constraints.
    v_bias : cpVect;
    w_bias : cpFloat;

    // Space this body has been added to
    space : PcpSpace;

    // Pointer to the shape list.
    // Shapes form a linked list using cpShape.next when added to a space.
    shapesList : PcpShape;

    // Used by cpSpaceStep() to store contact graph information.
    node : cpComponentNode;
  end;

// CONSTRAINTS
  cpConstraintPreStepFunction = procedure( constraint : PcpConstraint; dt : cpFloat; dt_inv : cpFloat ); cdecl;
  cpConstraintApplyImpulseFunction = procedure( constraint : PcpConstraint ); cdecl;
  cpConstraintGetImpulseFunction = function( constraint : PcpConstraint ) : cpFloat; cdecl;

  cpConstraintClass = record
    preStep : cpConstraintPreStepFunction;
    applyImpulse : cpConstraintApplyImpulseFunction;
    getImpulse : cpConstraintGetImpulseFunction;
  end;

  cpConstraint = record
    klass : PcpConstraintClass;

    a, b : PcpBody;
    maxForce : cpFloat;
    biasCoef : cpFloat;
    maxBias : cpFloat;

    data : cpDataPointer;
  end;

  cpPinJoint = record
    constraint : cpConstraint;
    anchr1, anchr2 : cpVect;
    dist : cpFloat;

    r1, r2 : cpVect;
    n : cpVect;
    nMass : cpFloat;

    jnAcc, jnMax : cpFloat;
    bias : cpFloat;
  end;

  cpSlideJoint = record
    constraint : cpConstraint;
    anchr1, anchr2 : cpVect;
    min, max : cpFloat;

    r1, r2 : cpVect;
    n : cpVect;
    nMass : cpFloat;

    jnAcc, jnMax : cpFloat;
    bias : cpFloat;
  end;

  cpPivotJoint = record
    constraint : cpConstraint;
    anchr1, anchr2 : cpVect;

    r1, r2 : cpVect;
    k1, k2 : cpVect;

    jAcc : cpVect;
    jMaxLen : cpFloat;
    bias : cpVect;
  end;

  cpGrooveJoint = record
    constraint : cpConstraint;
    grv_n, grv_a, grv_b : cpVect;
    anchr2 : cpVect;

    grv_tn : cpVect;
    clamp : cpFloat;
    r1, r2 : cpVect;
    k1, k2 : cpVect;

    jAcc : cpVect;
    jMaxLen : cpFloat;
    bias : cpVect;
  end;

  cpDampedSpringForceFunc = function( spring : PcpConstraint; dist : cpFloat ) : cpFloat; cdecl;

  cpDampedSpring = record
    constraint : cpConstraint;
    anchr1, anchr2 : cpVect;
    restLength : cpFloat;
    stiffness : cpFloat;
    damping : cpFloat;
    springForceFunc : cpDampedSpringForceFunc;

    target_vrn : cpFloat;
    v_coef : cpFloat;

    r1, r2 : cpVect;
    nMass : cpFloat;
    n : cpVect;
  end;

  cpDampedRotarySpringTorqueFunc = function( spring : PcpConstraint; relativeAngle : cpFloat ) : cpFloat; cdecl;

  cpDampedRotarySpring = record
    constraint : cpConstraint;
    restAngle : cpFloat;
    stiffness : cpFloat;
    damping : cpFloat;
    springTorqueFunc : cpDampedRotarySpringTorqueFunc;

    target_wrn : cpFloat;
    w_coef : cpFloat;

    iSum : cpFloat;
  end;

  cpRotaryLimitJoint = record
    constraint : cpConstraint;
    min, max : cpFloat;

    iSum : cpFloat;

    bias : cpFloat;
    jAcc, jMax : cpFloat;
  end;

  cpRatchetJoint = record
    constraint : cpConstraint;
    angle, phase, ratchet : cpFloat;

    iSum : cpFloat;

    bias : cpFloat;
    jAcc, jMax : cpFloat;
  end;

  cpGearJoint = record
    constraint : cpConstraint;
    phase, ratio : cpFloat;
    ratio_inv : cpFloat;

    iSum : cpFloat;

    bias : cpFloat;
    jAcc, jMax : cpFloat;
  end;

  cpSimpleMotor = record
    constraint : cpConstraint;
    rate : cpFloat;

    iSum : cpFloat;

    jAcc, jMax : cpFloat;
  end;

// SPACE
  // User collision handler function types.
  cpCollisionBeginFunc = function( arb : PcpArbiter; space : PcpSpace; data : Pointer ) : cpBool; cdecl;
  cpCollisionPreSolveFunc = function( arb : PcpArbiter; space : PcpSpace; data : Pointer ) : cpBool; cdecl;
  cpCollisionPostSolveFunc = procedure( arb : PcpArbiter; space : PcpSpace; data : Pointer ); cdecl;
  cpCollisionSeparateFunc = procedure( arb : PcpArbiter; space : PcpSpace; data : Pointer ); cdecl;

  // Structure for holding collision pair function information.
  // Used internally.
  cpCollisionHandler = record
    a : cpCollisionType;
    b : cpCollisionType;
    _begin : cpCollisionBeginFunc;
    preSolve : cpCollisionPreSolveFunc;
    postSolve : cpCollisionPostSolveFunc;
    separate : cpCollisionSeparateFunc;
    data : Pointer;
  end;

  cpContactBufferHeader = record
    stamp : cpTimestamp;
    next : PcpContactBufferHeader;
    numContacts : LongWord;
  end;

  cpSpace = record
    // *** User definable fields

    // Number of iterations to use in the impulse solver to solve contacts.
    iterations : Integer;

    // Number of iterations to use in the impulse solver to solve elastic collisions.
    elasticIterations : Integer;

    // Default gravity to supply when integrating rigid body motions.
    gravity : cpVect;

    // Default damping to supply when integrating rigid body motions.
    damping : cpFloat;

    // Speed threshold for a body to be considered idle.
    // The default value of 0 means to let the space guess a good threshold based on gravity.
    idleSpeedThreshold : cpFloat;

    // Time a group of bodies must remain idle in order to fall asleep
    // The default value of INFINITY disables the sleeping algorithm.
    sleepTimeThreshold : cpFloat;

    // *** Internally

    // When the space is locked, you should not add or remove objects;
    locked : cpBool;

    // Time stamp. Is incremented on every call to cpSpaceStep().
    stamp : cpTimestamp;

    // The static and active shape spatial hashes.
    staticShapes : PcpSpaceHash;
    activeShapes : PcpSpaceHash;

    // List of bodies in the system.
    bodies : PcpArray;

    // List of groups of sleeping bodies.
    sleepingComponents : PcpArray;

    // List of active arbiters for the impulse solver.
    arbiters : PcpArray;
    pooledArbiters : PcpArray;

    // Linked list ring of contact buffers.
    // Head is the newest buffer, and each buffer points to a newer buffer.
    // Head wraps around and points to the oldest (tail) buffer.
    contactBuffersHead : PcpContactBufferHeader;
    _contactBuffersTail : PcpContactBufferHeader;

    // List of buffers to be free()ed when destroying the space.
    allocatedBuffers : PcpArray;

    // Persistant contact set.
    contactSet : PcpHashSet;

    // List of constraints in the system.
    constraints : PcpArray;

    // Set of collisionpair functions.
    collFuncSet : PcpHashSet;
    // Default collision handler.
    defaultHandler : cpCollisionHandler;

    postStepCallbacks : PcpHashSet;

    staticBody : cpBody;
  end;

  cpPostStepFunc = procedure( space : PcpSpace; obj : Pointer; data : Pointer ); cdecl;
  cpSpacePointQueryFunc = procedure( shape : PcpShape; data : Pointer ); cdecl;
  cpSpaceSegmentQueryFunc = procedure( shape : PcpShape; t : cpFloat; n : cpVect; data : Pointer ); cdecl;
  cpSpaceBBQueryFunc = procedure( shape : PcpShape; data : Pointer ); cdecl;
  cpSpaceBodyIterator = procedure( body : PcpBody; data : Pointer ); cdecl;

// HASHSET
// cpHashSet uses a chained hashtable implementation.
// Other than the transformation functions, there is nothing fancy going on.

  // cpHashSetBin's form the linked lists in the chained hash table.
  cpHashSetBin = record
    // Pointer to the element.
    elt : Pointer;
    // Hash value of the element.
    hash : cpHashValue;
    // Next element in the chain.
    next : PcpHashSetBin;
  end;

  // Equality function. Returns true if ptr is equal to elt.
  cpHashSetEqlFunc = function( ptr : Pointer; elt : Pointer ) : cpBool; cdecl;
  // Used by cpHashSetInsert(). Called to transform the ptr into an element.
  cpHashSetTransFunc = function( ptr : Pointer; date : Pointer ) : Pointer; cdecl;

  cpHashSet = record
    // Number of elements stored in the table.
    entries : Integer;
    // Number of cells in the table.
    size : Integer;

    eql : cpHashSetEqlFunc;
    trans : cpHashSetTransFunc;

    // Default value returned by cpHashSetFind() when no element is found.
    // Defaults to NULL.
    default_value : Pointer;

    // The table and recycled bins
    table : PPcpHashSetBin;
    pooledBins : PcpHashSetBin;

    allocatedBuffers : PcpArray;
  end;

  // Iterate over a hashset.
  cpHashSetIterFunc = procedure( elt : Pointer; data : Pointer ); cdecl;

// SPACE HASH
// The spatial hash is Chipmunk's default (and currently only) spatial index type.
// Based on a chained hash table.
  // Used internally to track objects added to the hash
  cpHandle = record
    // Pointer to the object
    obj : Pointer;
    // Retain count
    retain : Integer;
    // Query stamp. Used to make sure two objects
    // aren't identified twice in the same query.
    stamp : cpTimestamp;
  end;

  // Linked list element for in the chains.
  cpSpaceHashBin = record
    handle : PcpHandle;
    next : PcpSpaceHashBin;
  end;

  // BBox callback. Called whenever the hash needs a bounding box from an object.
  cpSpaceHashBBFunc = function( obj : Pointer ) : cpBB; cdecl;

  cpSpaceHash = record
    // Number of cells in the table.
    numcells : Integer;
    // Dimentions of the cells.
    clldim : cpFloat;

    // BBox callback.
    bbfunc : cpSpaceHashBBFunc;

    // Hashset of the handles and the recycled ones.
    handleSet : PcpHashSet;
    pooledHandles : PcpArray;

    // The table and the recycled bins.
    table : PPcpSpaceHashBin;
    pooledBins : PcpSpaceHashBin;

    // list of buffers to free on destruction.
    allocatedBuffers : PcpArray;

    // Incremented on each query. See cpHandle.stamp.
    stamp : cpTimestamp;
  end;

  // Iterator function
  cpSpaceHashIterator = procedure( obj : Pointer; data : Pointer ); cdecl;

  // Query callback.
  cpSpaceHashQueryFunc = procedure( obj1 : Pointer; obj2 : Pointer; data : Pointer ); cdecl;

  // Segment Query callback.
  // Return value is uesd for early exits of the query.
  // If while traversing the grid, the raytrace function detects that an entire grid cell is beyond the hit point, it will stop the trace.
  cpSpaceHashSegmentQueryFunc = function( obj1 : Pointer; obj2 : Pointer; data : Pointer ) : cpFloat; cdecl;

const
  cpvzero : cpVect = ( x: 0; y : 0 );
  cpFalse : cpBool = FALSE;
  cpTrue  : cpBool = TRUE;
  INFINITY                    = 1e1000;
  CP_MAX_CONTACTS_PER_ARBITER = 6;

// компиляция внутри???
{$IF ( not DEFINED( USE_CHIPMUNK_STATIC ) ) and ( not DEFINED( USE_CHIPMUNK_LINK ) )}
var
  cpInitChipmunk : procedure; cdecl;
  cpMomentForCircle : function( m : cpFloat; r1 : cpFloat; r2 : cpFloat; offset : cpVect ) : cpFloat; cdecl;
  cpMomentForSegment : function( m : cpFloat; a : cpVect; b : cpVect ) : cpFloat; cdecl;
  cpMomentForPoly : function( m : cpFloat; numVerts : Integer; verts : PcpVect; offset : cpVect ) : cpFloat; cdecl;
  cpMomentForBox : function( m : cpFloat; width : cpFloat; height : cpFloat ) : cpFloat; cdecl;

// VECT
  // Returns the length of v.
  cpvlength : function( v : cpVect ) : cpFloat; cdecl;

  // Spherical linearly interpolate between v1 and v2.
  cpvslerp : function ( v1 : cpVect; v2 : cpVect; t : cpFloat ) : cpVect; cdecl;

  // Spherical linearly interpolate between v1 towards v2 by no more than angle a radians
  cpvslerpconst : function( v1 : cpVect; v2 : cpVect; a : cpFloat ) : cpVect; cdecl;

  // Returns the unit length vector for the given angle (in radians).
  cpvforangle : function( a : cpFloat ) : cpVect; cdecl;

  // Returns the angular direction v is pointing in (in radians).
  cpvtoangle : function( v : cpVect ) : cpFloat; cdecl;

// BB
  cpBBClampVect : function( bb : cpBB; v : cpVect ) : cpVect; cdecl; // clamps the vector to lie within the bbox
  // TODO edge case issue
  cpBBWrapVect : function( bb : cpBB; v : cpVect ) : cpVect; cdecl; // wrap a vector to a bbox

// ARRAY
  cpArrayAlloc : function : PcpArray; cdecl;
  cpArrayInit : function( arr : PcpArray; size : Integer ) : PcpArray; cdecl;
  cpArrayNew : function( size : Integer ) : PcpArray; cdecl;

  cpArrayDestroy : procedure( arr : PcpArray); cdecl;
  cpArrayFree : procedure( arr : PcpArray ); cdecl;

  cpArrayClear : procedure( arr : PcpArray ); cdecl;

  cpArrayPush : procedure( arr : PcpArray; _object : Pointer ); cdecl;
  cpArrayPop : function( arr : PcpArray ) : Pointer; cdecl;
  cpArrayDeleteIndex : procedure( arr : PcpArray; idx : Integer ); cdecl;
  cpArrayDeleteObj : procedure( arr : PcpArray; obj : Pointer ); cdecl;

  cpArrayAppend : procedure( arr : PcpArray; other : PcpArray ); cdecl;

  cpArrayEach : procedure( arr : PcpArray; iterFunc : cpArrayIter; data : Pointer ); cdecl;
  cpArrayContains : function( arr : PcpArray; ptr : Pointer ) : cpBool; cdecl;

// ARBITER
  // Contacts are always allocated in groups.
  cpContactInit : function( con : PcpContact; p : cpVect; n : cpVect; dist : cpFloat; hasg : cpHashValue ) : PcpContact; cdecl;

  // Arbiters are allocated in large buffers by the space and don't require a destroy function
  cpArbiterInit : function( arb : PcpArbiter; a : PcpShape; b : PcpShape ) : PcpArbiter; cdecl;

  // These functions are all intended to be used internally.
  // Inject new contact points into the arbiter while preserving contact history.
  cpArbiterUpdate : procedure( arb : PcpArbiter; contacts : PcpContact; numContacts : Integer; handler : PcpCollisionHandler; a : PcpShape; b : PcpShape ); cdecl;
  // Precalculate values used by the solver.
  cpArbiterPreStep : procedure( arb : PcpArbiter; dt_inv : cpFloat ); cdecl;
  cpArbiterApplyCachedImpulse : procedure( arb : PcpArbiter ); cdecl;
  // Run an iteration of the solver on the arbiter.
  cpArbiterApplyImpulse : procedure( arb : PcpArbiter; eCoef : cpFloat ); cdecl;

  // Arbiter Helper Functions
  cpArbiterTotalImpulse : function( arb : PcpArbiter ) : cpVect; cdecl;
  cpArbiterTotalImpulseWithFriction : function( arb : PcpArbiter ) : cpVect; cdecl;
  cpArbiterIgnore : procedure( arb : PcpArbiter ); cdecl;

// SHAPE
  // Low level shape initialization func.
  cpShapeInit : function( shape : PcpShape; klass : PcpShapeClass; body : PcpBody ) : PcpShape; cdecl;

  // Basic destructor functions. (allocation functions are not shared)
  cpShapeDestroy : procedure( shape : PcpShape ); cdecl;
  cpShapeFree : procedure( shape : PcpShape ); cdecl;

  // Cache the BBox of the shape.
  cpShapeCacheBB : function( shape : PcpShape ) : cpBB; cdecl;

  // Test if a point lies within a shape.
  cpShapePointQuery : function( shape : PcpShape; p : cpVect ) : cpBool; cdecl;

// CIRCLESHAPE
  // Basic allocation functions for cpCircleShape.
  cpCircleShapeAlloc : function : cpCircleShape; cdecl;
  cpCircleShapeInit : function( circle : PcpCircleShape; body : PcpBody; radius : cpFloat; offset : cpVect ) : PcpCircleShape; cdecl;
  cpCircleShapeNew : function( body : PcpBody; radius : cpFloat; offset : cpVect ) : PcpShape; cdecl;

// SEGMENTSHAPE
  // Basic allocation functions for cpSegmentShape.
  cpSegmentShapeAlloc : function : PcpSegmentShape; cdecl;
  cpSegmentShapeInit : function( seg : PcpSegmentShape; body : PcpBody; a : cpVect; b : cpVect; radius : cpFloat ) : PcpSegmentShape; cdecl;
  cpSegmentShapeNew : function( body : PcpBody; a : cpVect; b : cpVect; radius : cpFloat ) : PcpShape; cdecl;

  cpResetShapeIdCounter : procedure; cdecl;

  cpShapeSegmentQuery : function( shape : PcpShape; a : cpVect; b : cpVect; info : PcpSegmentQueryInfo ) : cpBool; cdecl;

// POLYSHAPE
  // Basic allocation functions.
  cpPolyShapeAlloc : function : PcpPolyShape; cdecl;
  cpPolyShapeInit : function ( poly : PcpPolyShape; body : PcpBody; numVerts : Integer; verts : PcpVect; offset : cpVect ) : PcpPolyShape; cdecl;
  cpPolyShapeNew : function( body : PcpBody; numVerts : Integer; verts : PcpVect; offset : cpVect ) : PcpShape; cdecl;

  cpBoxShapeInit : function( poly : PcpPolyShape; body : PcpBody; width : cpFloat; height : cpFloat ) : PcpPolyShape; cdecl;
  cpBoxShapeNew : function( body : PcpBody; width : cpFloat; height : cpFloat ) : PcpShape; cdecl;

  // Check that a set of vertexes has a correct winding and that they are convex
  cpPolyValidate : function( verts : PcpVect; numVerts : Integer ) : cpBool; cdecl;

  cpPolyShapeGetNumVerts : function( shape : PcpShape ) : Integer; cdecl;
  cpPolyShapeGetVert : function( shape : PcpShape; idx : Integer ) : cpVect; cdecl;

// BODY
  // Basic allocation/destruction functions
  cpBodyAlloc : function : PcpBody; cdecl;
  cpBodyInit : function( body : PcpBody; m : cpFloat; i : cpFloat ) : PcpBody; cdecl;
  cpBodyNew : function( m : cpFloat; i : cpFloat ) : PcpBody; cdecl;

  cpBodyDestroy : procedure( body : PcpBody ); cdecl;
  cpBodyFree : procedure( body : PcpBody ); cdecl;

  // Wake up a sleeping or idle body. (defined in cpSpace.c)
  cpBodyActivate : procedure( body : PcpBody ); cdecl;

  // Force a body to sleep;
  cpBodySleep : procedure( body : PcpBody ); cdecl;

  cpBodySetMass : procedure( body : PcpBody; m : cpFloat ); cdecl;
  cpBodySetMoment : procedure( body : PcpBody; i : cpFloat ); cdecl;
  cpBodySetAngle : procedure( body : PcpBody; a : cpFloat ); cdecl;

  //  Modify the velocity of the body so that it will move to the specified absolute coordinates in the next timestep.
  // Intended for objects that are moved manually with a custom velocity integration function.
  cpBodySlew : procedure( body : PcpBody; pos : cpVect; dt : cpFloat ); cdecl;

  // Default Integration functions.
  cpBodyUpdateVelocity : procedure( body : PcpBody; gravity : cpVect; damping : cpFloat; dt : cpFloat ); cdecl;
  cpBodyUpdatePosition : procedure( body : PcpBody; dt : cpFloat ); cdecl;

  // Zero the forces on a body.
  cpBodyResetForces : procedure( body : PcpBody ); cdecl;
  // Apply a force (in world coordinates) to a body at a point relative to the center of gravity (also in world coordinates).
  cpBodyApplyForce : procedure( body : PcpBody; f : cpVect; r : cpVect ); cdecl;

  // Apply a damped spring force between two bodies.
  // Warning: Large damping values can be unstable. Use a cpDampedSpring constraint for this instead.
  cpApplyDampedSpring : procedure( a : PcpBody; b : PcpBody; anchr1 : cpVect; anchr2 : cpVect; rlen : cpFloat; k : cpFloat; dmp : cpFloat; dt : cpFloat ); cdecl;

// CONSTRAINTS
  cpConstraintDestroy : procedure( constraint : PcpConstraint ); cdecl;
  cpConstraintFree : procedure( constraint : PcpConstraint ); cdecl;

  cpPinJointGetClass: function: PcpConstraintClass; cdecl;
  cpPinJointAlloc : function : PcpPinJoint; cdecl;
  cpPinJointInit : function( joint : PcpPinJoint; a : PcpBody; b : PcpBody; anchr1 : cpVect; anchr2 : cpVect ) : PcpPinJoint; cdecl;
  cpPinJointNew : function( a : PcpBody; b : PcpBody; anchr1 : cpVect; anchr2 : cpVect ) : PcpConstraint; cdecl;

  cpSlideJointGetClass: function: PcpConstraintClass; cdecl;
  cpSlideJointAlloc : function : PcpSlideJoint; cdecl;
  cpSlideJointInit : function( joint : PcpSlideJoint; a : PcpBody; b : PcpBody; anchr1 : cpVect; anchr2 : cpVect; min : cpFloat; max : cpFloat ) : PcpSlideJoint; cdecl;
  cpSlideJointNew : function( a : PcpBody; b : PcpBody; anchr1 : cpVect; anchr2 : cpVect; min : cpFloat; max : cpFloat ) : PcpConstraint; cdecl;

  cpPivotJointGetClass: function: PcpConstraintClass; cdecl;
  cpPivotJointAlloc : function : PcpPivotJoint; cdecl;
  cpPivotJointInit : function( joint : PcpPivotJoint; a : PcpBody; b : PcpBody; anchr1 : cpVect; anchr2 : cpVect ) : PcpPivotJoint; cdecl;
  cpPivotJointNew : function( a : PcpBody; b : PcpBody; pivot : cpVect ) : PcpConstraint; cdecl;
  cpPivotJointNew2 : function( a : PcpBody; b : PcpBody; anchr1 : cpVect; anchr2 : cpVect ) : PcpConstraint; cdecl;

  cpGrooveJointGetClass: function: PcpConstraintClass; cdecl;
  cpGrooveJointAlloc : function : PcpGrooveJoint; cdecl;
  cpGrooveJointInit : function( joint : PcpGrooveJoint; a : PcpBody; b : PcpBody; groove_a : cpVect; groove_b : cpVect; anchr2 : cpVect ) : PcpGrooveJoint; cdecl;
  cpGrooveJointNew : function( a : PcpBody; b : PcpBody; groove_a : cpVect; groove_b : cpVect; anchr2 : cpVect ) : PcpConstraint; cdecl;

  cpGrooveJointSetGrooveA : procedure( constraint : PcpConstraint; value : cpVect ); cdecl;
  cpGrooveJointSetGrooveB : procedure( constraint : PcpConstraint; value : cpVect ); cdecl;

  cpDampedSpringGetClass: function : PcpConstraintClass; cdecl;
  cpDampedSpringAlloc : function : PcpDampedSpring; cdecl;
  cpDampedSpringInit : function( joint : PcpDampedSpring; a : PcpBody; b : PcpBody; anchr1 : cpVect; anchr2 : cpVect; restLength : cpFloat; stiffness : cpFloat; damping : cpFloat ) : PcpDampedSpring; cdecl;
  cpDampedSpringNew : function( a : PcpBody; b : PcpBody; anchr1 : cpVect; anchr2 : cpVect; restLength : cpFloat; stiffness : cpFloat; damping : cpFloat ) : PcpConstraint; cdecl;

  cpDampedRotarySpringGetClass: function : PcpConstraintClass; cdecl;
  cpDampedRotarySpringAlloc : function : PcpDampedRotarySpring; cdecl;
  cpDampedRotarySpringInit : function( joint : PcpDampedRotarySpring; a : PcpBody; b : PcpBody; restAngle : cpFloat; stiffness : cpFloat; damping : cpFloat ) : PcpDampedRotarySpring; cdecl;
  cpDampedRotarySpringNew : function( a : PcpBody; b : PcpBody; restAngle : cpFloat; stiffness : cpFloat; damping : cpFloat ) : PcpConstraint; cdecl;

  cpRotaryLimitJointGetClass: function : PcpConstraintClass; cdecl;
  cpRotaryLimitJointAlloc : function : PcpRotaryLimitJoint; cdecl;
  cpRotaryLimitJointInit : function( joint : PcpRotaryLimitJoint; a : PcpBody; b : PcpBody; min : cpFloat; max : cpFloat ) : PcpRotaryLimitJoint; cdecl;
  cpRotaryLimitJointNew : function( a : PcpBody; b : PcpBody; min : cpFloat; max : cpFloat ) : PcpConstraint; cdecl;

  cpRatchetJointGetClass: function : PcpConstraintClass; cdecl;
  cpRatchetJointAlloc : function : PcpRatchetJoint; cdecl;
  cpRatchetJointInit : function( joint : PcpRatchetJoint; a : PcpBody; b : PcpBody; phase : cpFloat; ratchet : cpFloat ) : PcpRatchetJoint; cdecl;
  cpRatchetJointNew : function( a : PcpBody; b : PcpBody; phase : cpFloat; ratchet : cpFloat ) : PcpConstraint; cdecl;

  cpGearJointGetClass: function : PcpConstraintClass; cdecl;
  cpGearJointAlloc : function : PcpGearJoint; cdecl;
  cpGearJointInit : function( joint : PcpGearJoint; a : PcpBody; b : PcpBody; phase : cpFloat; ratio : cpFloat ) : PcpGearJoint; cdecl;
  cpGearJointNew : function( a : PcpBody; b : PcpBody; phase : cpFloat; ratio : cpFloat ) : PcpConstraint; cdecl;

  cpSimpleMotorGetClass: function : PcpConstraintClass; cdecl;
  cpSimpleMotorAlloc : function : PcpSimpleMotor; cdecl;
  cpSimpleMotorInit : function( joint : PcpSimpleMotor; a : PcpBody; b : PcpBody; rate : cpFloat ) : PcpSimpleMotor; cdecl;
  cpSimpleMotorNew : function( a : PcpBody; b : PcpBody; rate : cpFloat ) : PcpConstraint; cdecl;

// SPACE
  // Basic allocation/destruction functions.
  cpSpaceAlloc : function : PcpSpace; cdecl;
  cpSpaceInit : function( space : PcpSpace ) : PcpSpace; cdecl;
  cpSpaceNew : function : PcpSpace; cdecl;

  cpSpaceDestroy : procedure( space : PcpSpace ); cdecl;
  cpSpaceFree : procedure( space : PcpSpace ); cdecl;

  // Convenience function. Frees all referenced entities. (bodies, shapes and constraints)
  cpSpaceFreeChildren : procedure( space : PcpSpace ); cdecl;

// Collision handler management functions.
  cpSpaceSetDefaultCollisionHandler : procedure( space : PcpSpace; _begin : cpCollisionBeginFunc; preSolve : cpCollisionPreSolveFunc; postSolve : cpCollisionPostSolveFunc; separate : cpCollisionSeparateFunc; data : Pointer ); cdecl;
  cpSpaceAddCollisionHandler : procedure( space : PcpSpace; a : cpCollisionType; b : cpCollisionType; _begin : cpCollisionBeginFunc; preSolve : cpCollisionPreSolveFunc; postSolve : cpCollisionPostSolveFunc;  separate : cpCollisionSeparateFunc; data : Pointer ); cdecl;
  cpSpaceRemoveCollisionHandler : procedure( space : PcpSpace; a : cpCollisionType; b : cpCollisionType ); cdecl;

  // Add and remove entities from the system.
  cpSpaceAddShape : function( space : PcpSpace; shape : PcpShape ) : PcpShape; cdecl;
  cpSpaceAddStaticShape : function( space : PcpSpace; shape : PcpShape ) : PcpShape; cdecl;
  cpSpaceAddBody : function( space : PcpSpace; body : PcpBody ) : PcpBody; cdecl;
  cpSpaceAddConstraint : function( space : PcpSpace; constraint : PcpConstraint ) : PcpConstraint; cdecl;

  cpSpaceRemoveShape : procedure( space : PcpSpace; shape : PcpShape ); cdecl;
  cpSpaceRemoveStaticShape : procedure( space : PcpSpace; shape : PcpShape ); cdecl;
  cpSpaceRemoveBody : procedure( space : PcpSpace; body : PcpBody ); cdecl;
  cpSpaceRemoveConstraint : procedure( space : PcpSpace; constraint : PcpConstraint );  cdecl;

  // Register a post step function to be called after cpSpaceStep() has finished.
  // obj is used a key, you can only register one callback per unique value for obj
  cpSpaceAddPostStepCallback : procedure( space : PcpSpace; func : cpPostStepFunc; obj : Pointer; data : Pointer ); cdecl;

  // Point query callback function
  cpSpacePointQuery : procedure( space : PcpSpace; point : cpVect; layers : cpLayers; group : cpGroup; func : cpSpacePointQueryFunc; data : Pointer ); cdecl;
  cpSpacePointQueryFirst : function( space : PcpSpace; point : cpVect; layers : cpLayers; group : cpGroup ) : PcpShape; cdecl;

  // Segment query callback function
  cpSpaceSegmentQuery : procedure( space : PcpSpace; start : cpVect; _end : cpVect; layers : cpLayers; group : cpGroup; func : cpSpaceSegmentQueryFunc; data : Pointer ); cdecl;
  cpSpaceSegmentQueryFirst : function( space : PcpSpace; start : cpVect; _end : cpVect; layers : cpLayers; group : cpGroup; out info : cpSegmentQueryInfo ) : PcpShape; cdecl;

  // BB query callback function
  cpSpaceBBQuery : procedure( space : PcpSpace; bb : cpBB; layers : cpLayers; group : cpGroup; func : cpSpaceBBQueryFunc; data : Pointer ); cdecl;

  // Iterator function for iterating the bodies in a space.
  cpSpaceEachBody : procedure( space : PcpSpace; func : cpSpaceBodyIterator; data : Pointer ); cdecl;

  // Spatial hash management functions.
  cpSpaceResizeStaticHash : procedure( space : PcpSpace; dim : cpFloat; count : Integer ); cdecl;
  cpSpaceResizeActiveHash : procedure( space : PcpSpace; dim : cpFloat; count : Integer ); cdecl;
  cpSpaceRehashStatic : procedure( space : PcpSpace ); cdecl;

  cpSpaceRehashShape : procedure( space : PcpSpace; shape : PcpShape ); cdecl;

  // Update the space.
  cpSpaceStep : procedure( space : PcpSpace; dt : cpFloat ); cdecl;

// HASHSET
  // Basic allocation/destruction functions.
  cpHashSetDestroy : procedure( _set : PcpHashSet ); cdecl;
  cpHashSetFree : procedure( _set : PcpHashSet ); cdecl;

  cpHashSetAlloc : function : PcpHashSet; cdecl;
  cpHashSetInit : function( _set : PcpHashSet; size : Integer; eqlFunc : cpHashSetEqlFunc; trans : cpHashSetTransFunc ) : PcpHashSet; cdecl;
  cpHashSetNew : function( size : Integer; eqlFunc : cpHashSetEqlFunc; trans : cpHashSetTransFunc ) : PcpHashSet; cdecl;

  // Insert an element into the set, returns the element.
  // If it doesn't already exist, the transformation function is applied.
  cpHashSetInsert : function( _set : PcpHashSet; hash : cpHashValue; ptr : Pointer; data : Pointer ) : Pointer; cdecl;
  // Remove and return an element from the set.
  cpHashSetRemove : function( _set : PcpHashSet; hash : cpHashValue; ptr : Pointer ) : Pointer; cdecl;
  // Find an element in the set. Returns the default value if the element isn't found.
  cpHashSetFind : function( _set : PcpHashSet; hash : cpHashValue; ptr : Pointer ) : Pointer; cdecl;

  cpHashSetEach : procedure( _set : PcpHashSet; func : cpHashSetIterFunc; data : Pointer ); cdecl;

  cpHashSetFilter : procedure( _set : PcpHashSet; func : cpHashSetIterFunc; data : Pointer ); cdecl;

// SPACEHASH
  //Basic allocation/destruction functions.
  cpSpaceHashAlloc : function : PcpSpaceHash; cdecl;
  cpSpaceHashInit : function( hash : PcpSpaceHash; clldim : cpFloat; cells : Integer; bbfunc : cpSpaceHashBBFunc ) : PcpSpaceHash; cdecl;
  cpSpaceHashNew : function( clldim : cpFloat; cells : Integer; bbfunc : cpSpaceHashBBFunc ) : PcpSpaceHash; cdecl;

  cpSpaceHashDestroy : procedure( hash : PcpSpaceHash ); cdecl;
  cpSpaceHashFree : procedure( hash : PcpSpaceHash ); cdecl;

  // Resize the hashtable. (Does not rehash! You must call cpSpaceHashRehash() if needed.)
  cpSpaceHashResize : procedure( hash : PcpSpaceHash; celldim : cpFloat; numcells : Integer ); cdecl;

  // Add an object to the hash.
  cpSpaceHashInsert : procedure( hash : PcpSpaceHash; obj : Pointer; id : cpHashValue; _deprecated_ignored : cpBB ); cdecl;
  // Remove an object from the hash.
  cpSpaceHashRemove : procedure( hash : PcpSpaceHash; obj : Pointer; id : cpHashValue ); cdecl;

  // Iterate over the objects in the hash.
  cpSpaceHashEach : procedure( hash : PcpSpaceHash; func : cpSpaceHashIterator; data : Pointer ); cdecl;

  // Rehash the contents of the hash.
  cpSpaceHashRehash : procedure( hash : PcpSpaceHash ); cdecl;
  // Rehash only a specific object.
  cpSpaceHashRehashObject : procedure( hash : PcpSpaceHash; obj : Pointer; id : cpHashValue ); cdecl;

  // Point query the hash. A reference to the query point is passed as obj1 to the query callback.
  cpSpaceHashPointQuery : procedure( hash : PcpSpaceHash; point : cpVect; func : cpSpaceHashQueryFunc; data : Pointer ); cdecl;
  // Query the hash for a given BBox.
  cpSpaceHashQuery : procedure( hash : PcpSpaceHash; obj : Pointer; bb : cpBB; func : cpSpaceHashQueryFunc; data : Pointer ); cdecl;
  // Run a query for the object, then insert it. (Optimized case)
  cpSpaceHashQueryInsert : procedure( hash : PcpSpaceHash; obj : Pointer; bb : cpBB; func : cpSpaceHashQueryFunc; data : Pointer ); cdecl;
  // Rehashes while querying for each object. (Optimized case)
  cpSpaceHashQueryRehash : procedure( hash : PcpSpaceHash; func : cpSpaceHashQueryFunc; data : Pointer ); cdecl;

  cpSpaceHashSegmentQuery : procedure( hash : PcpSpaceHash; obj : Pointer; a : cpVect; b : cpVect; t_exit : cpFloat; func : cpSpaceHashSegmentQueryFunc; data : Pointer ); cdecl;

// COLLISION
  // Collides two cpShape structures.
  // Returns the number of contact points added to arr
  // which should be at least CP_MAX_CONTACTS_PER_ARBITER in length.
  // This function was very lonely in cpCollision.h :)
  cpCollideShapes : function( a : PcpShape; b : PcpShape; arr : PcpContact ) : Integer; cdecl;
{$ELSE}
  procedure cpInitChipmunk; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpMomentForCircle( m : cpFloat; r1 : cpFloat; r2 : cpFloat; offset : cpVect ) : cpFloat; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpMomentForSegment( m : cpFloat; a : cpVect; b : cpVect ) : cpFloat; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpMomentForPoly( m : cpFloat; numVerts : Integer; verts : PcpVect; offset : cpVect ) : cpFloat; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpMomentForBox( m : cpFloat; width : cpFloat; height : cpFloat ) : cpFloat; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpvlength( v : cpVect ) : cpFloat; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpvslerp ( v1 : cpVect; v2 : cpVect; t : cpFloat ) : cpVect; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpvslerpconst( v1 : cpVect; v2 : cpVect; a : cpFloat ) : cpVect; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpvforangle( a : cpFloat ) : cpVect; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpvtoangle( v : cpVect ) : cpFloat; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpBBClampVect( bb : cpBB; v : cpVect ) : cpVect; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpBBWrapVect( bb : cpBB; v : cpVect ) : cpVect; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpArrayAlloc : PcpArray; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpArrayInit( arr : PcpArray; size : Integer ) : PcpArray; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpArrayNew( size : Integer ) : PcpArray; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpArrayDestroy( arr : PcpArray); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpArrayFree( arr : PcpArray ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpArrayClear( arr : PcpArray ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpArrayPush( arr : PcpArray; _object : Pointer ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpArrayPop( arr : PcpArray ) : Pointer; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpArrayDeleteIndex( arr : PcpArray; idx : Integer ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpArrayDeleteObj( arr : PcpArray; obj : Pointer ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpArrayAppend( arr : PcpArray; other : PcpArray ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpArrayEach( arr : PcpArray; iterFunc : cpArrayIter; data : Pointer ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpArrayContains( arr : PcpArray; ptr : Pointer ) : cpBool; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpContactInit( con : PcpContact; p : cpVect; n : cpVect; dist : cpFloat; hasg : cpHashValue ) : PcpContact; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpArbiterInit( arb : PcpArbiter; a : PcpShape; b : PcpShape ) : PcpArbiter; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpArbiterUpdate( arb : PcpArbiter; contacts : PcpContact; numContacts : Integer; handler : PcpCollisionHandler; a : PcpShape; b : PcpShape ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpArbiterPreStep( arb : PcpArbiter; dt_inv : cpFloat ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpArbiterApplyCachedImpulse( arb : PcpArbiter ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpArbiterApplyImpulse( arb : PcpArbiter; eCoef : cpFloat ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpArbiterTotalImpulse( arb : PcpArbiter ) : cpVect; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpArbiterTotalImpulseWithFriction( arb : PcpArbiter ) : cpVect; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpArbiterIgnore( arb : PcpArbiter ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpShapeInit( shape : PcpShape; klass : PcpShapeClass; body : PcpBody ) : PcpShape; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpShapeDestroy( shape : PcpShape ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpShapeFree( shape : PcpShape ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpShapeCacheBB( shape : PcpShape ) : cpBB; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpShapePointQuery( shape : PcpShape; p : cpVect ) : cpBool; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpCircleShapeAlloc : cpCircleShape; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpCircleShapeInit( circle : PcpCircleShape; body : PcpBody; radius : cpFloat; offset : cpVect ) : PcpCircleShape; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpCircleShapeNew( body : PcpBody; radius : cpFloat; offset : cpVect ) : PcpShape; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpSegmentShapeAlloc : PcpSegmentShape; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpSegmentShapeInit( seg : PcpSegmentShape; body : PcpBody; a : cpVect; b : cpVect; radius : cpFloat ) : PcpSegmentShape; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpSegmentShapeNew( body : PcpBody; a : cpVect; b : cpVect; radius : cpFloat ) : PcpShape; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpResetShapeIdCounter; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpShapeSegmentQuery( shape : PcpShape; a : cpVect; b : cpVect; info : PcpSegmentQueryInfo ) : cpBool; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpPolyShapeAlloc : PcpPolyShape; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpPolyShapeInit ( poly : PcpPolyShape; body : PcpBody; numVerts : Integer; verts : PcpVect; offset : cpVect ) : PcpPolyShape; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpPolyShapeNew( body : PcpBody; numVerts : Integer; verts : PcpVect; offset : cpVect ) : PcpShape; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpBoxShapeInit( poly : PcpPolyShape; body : PcpBody; width : cpFloat; height : cpFloat ) : PcpPolyShape; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpBoxShapeNew( body : PcpBody; width : cpFloat; height : cpFloat ) : PcpShape; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpPolyValidate( verts : PcpVect; numVerts : Integer ) : cpBool; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpPolyShapeGetNumVerts( shape : PcpShape ) : Integer; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpPolyShapeGetVert( shape : PcpShape; idx : Integer ) : cpVect; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpBodyAlloc : PcpBody; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpBodyInit( body : PcpBody; m : cpFloat; i : cpFloat ) : PcpBody; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpBodyNew( m : cpFloat; i : cpFloat ) : PcpBody; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpBodyDestroy( body : PcpBody ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpBodyFree( body : PcpBody ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpBodyActivate( body : PcpBody ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpBodySleep( body : PcpBody ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpBodySetMass( body : PcpBody; m : cpFloat ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpBodySetMoment( body : PcpBody; i : cpFloat ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpBodySetAngle( body : PcpBody; a : cpFloat ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpBodySlew( body : PcpBody; pos : cpVect; dt : cpFloat ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpBodyUpdateVelocity( body : PcpBody; gravity : cpVect; damping : cpFloat; dt : cpFloat ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpBodyUpdatePosition( body : PcpBody; dt : cpFloat ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpBodyResetForces( body : PcpBody ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpBodyApplyForce( body : PcpBody; f : cpVect; r : cpVect ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpApplyDampedSpring( a : PcpBody; b : PcpBody; anchr1 : cpVect; anchr2 : cpVect; rlen : cpFloat; k : cpFloat; dmp : cpFloat; dt : cpFloat ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpConstraintDestroy( constraint : PcpConstraint ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpConstraintFree( constraint : PcpConstraint ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpPinJointAlloc : PcpPinJoint; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpPinJointInit( joint : PcpPinJoint; a : PcpBody; b : PcpBody; anchr1 : cpVect; anchr2 : cpVect ) : PcpPinJoint; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpPinJointNew( a : PcpBody; b : PcpBody; anchr1 : cpVect; anchr2 : cpVect ) : PcpConstraint; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpSlideJointAlloc : PcpSlideJoint; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpSlideJointInit( joint : PcpSlideJoint; a : PcpBody; b : PcpBody; anchr1 : cpVect; anchr2 : cpVect; min : cpFloat; max : cpFloat ) : PcpSlideJoint; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpSlideJointNew( a : PcpBody; b : PcpBody; anchr1 : cpVect; anchr2 : cpVect; min : cpFloat; max : cpFloat ) : PcpConstraint; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpPivotJointAlloc : PcpPivotJoint; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpPivotJointInit( joint : PcpPivotJoint; a : PcpBody; b : PcpBody; anchr1 : cpVect; anchr2 : cpVect ) : PcpPivotJoint; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpPivotJointNew( a : PcpBody; b : PcpBody; pivot : cpVect ) : PcpConstraint; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpPivotJointNew2( a : PcpBody; b : PcpBody; anchr1 : cpVect; anchr2 : cpVect ) : PcpConstraint; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpGrooveJointAlloc : PcpGrooveJoint; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpGrooveJointInit( joint : PcpGrooveJoint; a : PcpBody; b : PcpBody; groove_a : cpVect; groove_b : cpVect; anchr2 : cpVect ) : PcpGrooveJoint; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpGrooveJointNew( a : PcpBody; b : PcpBody; groove_a : cpVect; groove_b : cpVect; anchr2 : cpVect ) : PcpConstraint; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpGrooveJointSetGrooveA( constraint : PcpConstraint; value : cpVect ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpGrooveJointSetGrooveB( constraint : PcpConstraint; value : cpVect ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpDampedSpringAlloc : PcpDampedSpring; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpDampedSpringInit( joint : PcpDampedSpring; a : PcpBody; b : PcpBody; anchr1 : cpVect; anchr2 : cpVect; restLength : cpFloat; stiffness : cpFloat; damping : cpFloat ) : PcpDampedSpring; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpDampedSpringNew( a : PcpBody; b : PcpBody; anchr1 : cpVect; anchr2 : cpVect; restLength : cpFloat; stiffness : cpFloat; damping : cpFloat ) : PcpConstraint; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpDampedRotarySpringAlloc : PcpDampedRotarySpring; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpDampedRotarySpringInit( joint : PcpDampedRotarySpring; a : PcpBody; b : PcpBody; restAngle : cpFloat; stiffness : cpFloat; damping : cpFloat ) : PcpDampedRotarySpring; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpDampedRotarySpringNew( a : PcpBody; b : PcpBody; restAngle : cpFloat; stiffness : cpFloat; damping : cpFloat ) : PcpConstraint; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpRotaryLimitJointAlloc : PcpRotaryLimitJoint; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpRotaryLimitJointInit( joint : PcpRotaryLimitJoint; a : PcpBody; b : PcpBody; min : cpFloat; max : cpFloat ) : PcpRotaryLimitJoint; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpRotaryLimitJointNew( a : PcpBody; b : PcpBody; min : cpFloat; max : cpFloat ) : PcpConstraint; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpRatchetJointAlloc : PcpRatchetJoint; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpRatchetJointInit( joint : PcpRatchetJoint; a : PcpBody; b : PcpBody; phase : cpFloat; ratchet : cpFloat ) : PcpRatchetJoint; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpRatchetJointNew( a : PcpBody; b : PcpBody; phase : cpFloat; ratchet : cpFloat ) : PcpConstraint; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpGearJointAlloc : PcpGearJoint; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpGearJointInit( joint : PcpGearJoint; a : PcpBody; b : PcpBody; phase : cpFloat; ratio : cpFloat ) : PcpGearJoint; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpGearJointNew( a : PcpBody; b : PcpBody; phase : cpFloat; ratio : cpFloat ) : PcpConstraint; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpSimpleMotorAlloc : PcpSimpleMotor; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpSimpleMotorInit( joint : PcpSimpleMotor; a : PcpBody; b : PcpBody; rate : cpFloat ) : PcpSimpleMotor; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpSimpleMotorNew( a : PcpBody; b : PcpBody; rate : cpFloat ) : PcpConstraint; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpSpaceAlloc : PcpSpace; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpSpaceInit( space : PcpSpace ) : PcpSpace; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpSpaceNew : PcpSpace; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpSpaceDestroy( space : PcpSpace ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpSpaceFree( space : PcpSpace ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpSpaceFreeChildren( space : PcpSpace ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpSpaceSetDefaultCollisionHandler( space : PcpSpace; _begin : cpCollisionBeginFunc; preSolve : cpCollisionPreSolveFunc; postSolve : cpCollisionPostSolveFunc; separate : cpCollisionSeparateFunc; data : Pointer ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpSpaceAddCollisionHandler( space : PcpSpace; a : cpCollisionType; b : cpCollisionType; _begin : cpCollisionBeginFunc; preSolve : cpCollisionPreSolveFunc; postSolve : cpCollisionPostSolveFunc;  separate : cpCollisionSeparateFunc; data : Pointer ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpSpaceRemoveCollisionHandler( space : PcpSpace; a : cpCollisionType; b : cpCollisionType ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpSpaceAddShape( space : PcpSpace; shape : PcpShape ) : PcpShape; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpSpaceAddStaticShape( space : PcpSpace; shape : PcpShape ) : PcpShape; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpSpaceAddBody( space : PcpSpace; body : PcpBody ) : PcpBody; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpSpaceAddConstraint( space : PcpSpace; constraint : PcpConstraint ) : PcpConstraint; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpSpaceRemoveShape( space : PcpSpace; shape : PcpShape ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpSpaceRemoveStaticShape( space : PcpSpace; shape : PcpShape ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpSpaceRemoveBody( space : PcpSpace; body : PcpBody ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpSpaceRemoveConstraint( space : PcpSpace; constraint : PcpConstraint );  cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpSpaceAddPostStepCallback( space : PcpSpace; func : cpPostStepFunc; obj : Pointer; data : Pointer ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpSpacePointQuery( space : PcpSpace; point : cpVect; layers : cpLayers; group : cpGroup; func : cpSpacePointQueryFunc; data : Pointer ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpSpacePointQueryFirst( space : PcpSpace; point : cpVect; layers : cpLayers; group : cpGroup ) : PcpShape; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpSpaceSegmentQuery( space : PcpSpace; start : cpVect; _end : cpVect; layers : cpLayers; group : cpGroup; func : cpSpaceSegmentQueryFunc; data : Pointer ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpSpaceSegmentQueryFirst( space : PcpSpace; start : cpVect; _end : cpVect; layers : cpLayers; group : cpGroup; out info : cpSegmentQueryInfo ) : PcpShape; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpSpaceBBQuery( space : PcpSpace; bb : cpBB; layers : cpLayers; group : cpGroup; func : cpSpaceBBQueryFunc; data : Pointer ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpSpaceEachBody( space : PcpSpace; func : cpSpaceBodyIterator; data : Pointer ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpSpaceResizeStaticHash( space : PcpSpace; dim : cpFloat; count : Integer ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpSpaceResizeActiveHash( space : PcpSpace; dim : cpFloat; count : Integer ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpSpaceRehashStatic( space : PcpSpace ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpSpaceRehashShape( space : PcpSpace; shape : PcpShape ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpSpaceStep( space : PcpSpace; dt : cpFloat ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpHashSetDestroy( _set : PcpHashSet ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpHashSetFree( _set : PcpHashSet ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpHashSetAlloc : PcpHashSet; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpHashSetInit( _set : PcpHashSet; size : Integer; eqlFunc : cpHashSetEqlFunc; trans : cpHashSetTransFunc ) : PcpHashSet; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpHashSetNew( size : Integer; eqlFunc : cpHashSetEqlFunc; trans : cpHashSetTransFunc ) : PcpHashSet; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpHashSetInsert( _set : PcpHashSet; hash : cpHashValue; ptr : Pointer; data : Pointer ) : Pointer; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpHashSetRemove( _set : PcpHashSet; hash : cpHashValue; ptr : Pointer ) : Pointer; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpHashSetFind( _set : PcpHashSet; hash : cpHashValue; ptr : Pointer ) : Pointer; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpHashSetEach( _set : PcpHashSet; func : cpHashSetIterFunc; data : Pointer ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpHashSetFilter( _set : PcpHashSet; func : cpHashSetIterFunc; data : Pointer ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpSpaceHashAlloc : PcpSpaceHash; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpSpaceHashInit( hash : PcpSpaceHash; clldim : cpFloat; cells : Integer; bbfunc : cpSpaceHashBBFunc ) : PcpSpaceHash; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpSpaceHashNew( clldim : cpFloat; cells : Integer; bbfunc : cpSpaceHashBBFunc ) : PcpSpaceHash; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpSpaceHashDestroy( hash : PcpSpaceHash ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpSpaceHashFree( hash : PcpSpaceHash ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpSpaceHashResize( hash : PcpSpaceHash; celldim : cpFloat; numcells : Integer ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpSpaceHashInsert( hash : PcpSpaceHash; obj : Pointer; id : cpHashValue; _deprecated_ignored : cpBB ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpSpaceHashRemove( hash : PcpSpaceHash; obj : Pointer; id : cpHashValue ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpSpaceHashEach( hash : PcpSpaceHash; func : cpSpaceHashIterator; data : Pointer ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpSpaceHashRehash( hash : PcpSpaceHash ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpSpaceHashRehashObject( hash : PcpSpaceHash; obj : Pointer; id : cpHashValue ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpSpaceHashPointQuery( hash : PcpSpaceHash; point : cpVect; func : cpSpaceHashQueryFunc; data : Pointer ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpSpaceHashQuery( hash : PcpSpaceHash; obj : Pointer; bb : cpBB; func : cpSpaceHashQueryFunc; data : Pointer ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpSpaceHashQueryInsert( hash : PcpSpaceHash; obj : Pointer; bb : cpBB; func : cpSpaceHashQueryFunc; data : Pointer ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpSpaceHashQueryRehash( hash : PcpSpaceHash; func : cpSpaceHashQueryFunc; data : Pointer ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  procedure cpSpaceHashSegmentQuery( hash : PcpSpaceHash; obj : Pointer; a : cpVect; b : cpVect; t_exit : cpFloat; func : cpSpaceHashSegmentQueryFunc; data : Pointer ); cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
  function cpCollideShapes( a : PcpShape; b : PcpShape; arr : PcpContact ) : Integer; cdecl;{$IFDEF USE_CHIPMUNK_LINK} external libChipmunk; {$ELSE} external; {$ENDIF}
{$IFEND}

//
function cpfmin( a, b : cpFloat ) : cpFloat;
function cpfmax( a, b : cpFloat ) : cpFloat;

// VECT
// Convenience constructor for cpVect structs.
function cpv( x : cpFloat; y : cpFloat ) : cpVect;
// Check if two vectors are equal. (Be careful when comparing floating point numbers!)
function cpveql( v1 : cpVect; v2 : cpVect ) : cpBool;
// Add two vectors
function cpvadd( v1 : cpVect; v2 : cpVect ) : cpVect;
// Negate a vector.
function cpvneg( v : cpVect ) : cpVect;
// Subtract two vectors.
function cpvsub( v1 : cpVect; v2 : cpVect ) : cpVect;
// Scalar multiplication.
function cpvmult( v : cpVect; s : cpFloat ) : cpVect;
// Vector dot product.
function cpvdot( v1 : cpVect; v2 : cpVect ) : cpFloat;
{
  2D vector cross product analog.
  The cross product of 2D vectors results in a 3D vector with only a z component.
  This function returns the magnitude of the z value.
}
function cpvcross( v1 : cpVect; v2 : cpVect ) : cpFloat;
// Returns a perpendicular vector. (90 degree rotation)
function cpvperp( v : cpVect ) : cpVect;
// Returns a perpendicular vector. (-90 degree rotation)
function cpvrperp( v : cpVect ) : cpVect;
// Returns the vector projection of v1 onto v2.
function cpvproject( v1 : cpVect; v2 : cpVect ) : cpVect;
// Uses complex number multiplication to rotate v1 by v2. Scaling will occur if v1 is not a unit vector.
function cpvrotate( v1 : cpVect; v2 : cpVect ) : cpVect;
// Inverse of cpvrotate().
function cpvunrotate( v1 : cpVect; v2 : cpVect ) : cpVect;
// Returns the squared length of v. Faster than cpvlength() when you only need to compare lengths.
function cpvlengthsq( v : cpVect ) : cpFloat;
// Linearly interpolate between v1 and v2.
function cpvlerp( v1 : cpVect; v2 : cpVect; t : cpFloat ) : cpVect;
// Returns a normalized copy of v.
function cpvnormalize( v : cpVect ) : cpVect;
// Returns a normalized copy of v or cpvzero if v was already cpvzero. Protects against divide by zero errors.
function cpvnormalize_safe( v : cpVect ) : cpVect;
// Clamp v to length len.
function cpvclamp( v : cpVect; len : cpFloat ) : cpVect;
// Linearly interpolate between v1 towards v2 by distance d.
function cpvlerpconst( v1 : cpVect; v2 : cpVect; d : cpFloat ) : cpVect;
// Returns the distance between v1 and v2.
function cpvdist( v1 : cpVect; v2 : cpVect ) : cpFloat;
// Returns the squared distance between v1 and v2. Faster than cpvdist() when you only need to compare distances.
function cpvdistsq( v1 : cpVect; v2 : cpVect ) : cpFloat;
// Returns true if the distance between v1 and v2 is less than dist.
function cpvnear( v1 : cpVect; v2 : cpVect; dist : cpFloat ) : cpBool;

// BB
function cpBBNew( l : cpFloat; b : cpFloat; r : cpFloat; t : cpFloat ) : cpBB;
function cpBBintersects( a : cpBB; b : cpBB ) : cpBool;
function cpBBcontainsBB( bb : cpBB; other : cpBB ) : cpBool;
function cpBBcontainsVect( bb : cpBB; v : cpVect ) : cpBool;
function cpBBmerge( a : cpBB; b : cpBB ) : cpBB;
function cpBBexpand( bb : cpBB; v : cpVect ) : cpBB;

// ARBITER
procedure cpArbiterGetShapes( arb : PcpArbiter; a : PPcpShape; b : PPcpShape );
procedure cpArbiterGetBodies( arb : PcpArbiter; a : PPcpBody; b : PPcpBody );
function cpArbiterIsFirstContact( arb : PcpArbiter ) : cpBool;
function cpArbiterGetNormal( arb : PcpArbiter; i : Integer ) : cpVect;
function cpArbiterGetPoint( arb : PcpArbiter; i : Integer ) : cpVect;

// SEGMENTSHAPE
function cpSegmentQueryHitPoint( start : cpVect; _end : cpVect; info : cpSegmentQueryInfo ) : cpVect;
function cpSegmentQueryHitDist( start : cpVect; _end : cpVect; info : cpSegmentQueryInfo ) : cpFloat;

// POLYSHAPE
function cpPolyShapeValueOnAxis( poly : PcpPolyShape; n : cpVect; d : cpFloat ) : cpFloat;
// Returns true if the polygon contains the vertex.
function cpPolyShapeContainsVert( poly : PcpPolyShape; v : cpVect ) : cpBool;
// Same as cpPolyShapeContainsVert() but ignores faces pointing away from the normal.
function cpPolyShapeContainsVertPartial( poly : PcpPolyShape; v : cpVect; n : cpVect ) : cpBool;

// BODY
function cpBodyIsSleeping( body : PcpBody ) : cpBool;
function cpBodyIsRogue( body : PcpBody ) : cpBool;
function cpBodyLocal2World( body : PcpBody; v : cpVect ) : cpVect;
function cpBodyWorld2Local( body : PcpBody; v : cpVect ) : cpVect;
procedure cpBodyApplyImpulse( body : PcpBody; j : cpVect; r : cpVect );
function cpBodyKineticEnergy( body : PcpBody ) : cpFloat;

// CONSTRAINT
procedure cpConstraintActivateBodies( constraint : PcpConstraint );
function cpConstraintGetImpulse( constraint : PcpConstraint ) : cpFloat;

// ADDITIONAL FUNCTIONS FOR ZenGL
procedure cpDrawSpace( space : PcpSpace; DrawCollisions : Boolean );

var
  cpColorStatic    : LongWord = {$IfDef OLD_METHODS}$00FF00{$Else}cl_Green{$EndIf};
  cpColorActive    : LongWord = {$IfDef OLD_METHODS}$0000FF{$Else}cl_Blue{$EndIf};
  cpColorCollision : LongWord = {$IfDef OLD_METHODS}$FF0000{$Else}cl_Yellow05{$EndIf};

implementation

{$IF ( not DEFINED( USE_CHIPMUNK_STATIC ) ) and ( not DEFINED( USE_CHIPMUNK_LINK ) )}
{$IFDEF UNIX}
function dlopen ( Name : PChar; Flags : longint) : Pointer; cdecl; external 'dl';
function dlclose( Lib : Pointer) : Longint; cdecl; external 'dl';
function dlsym  ( Lib : Pointer; Name : Pchar) : Pointer; cdecl; external 'dl';
{$ENDIF}

{$IFDEF WINDOWS}
function dlopen ( lpLibFileName : PAnsiChar) : HMODULE; stdcall; external 'kernel32.dll' name 'LoadLibraryA';
function dlclose( hLibModule : HMODULE ) : Boolean; stdcall; external 'kernel32.dll' name 'FreeLibrary';
function dlsym  ( hModule : HMODULE; lpProcName : PAnsiChar) : Pointer; stdcall; external 'kernel32.dll' name 'GetProcAddress';

function MessageBoxA( hWnd : LongWord; lpText, lpCaption : PAnsiChar; uType : LongWord) : Integer; stdcall; external 'user32.dll';
{$ENDIF}

var
  cpLib : {$IFDEF UNIX} Pointer {$ENDIF} {$IFDEF WINDOWS} HMODULE {$ENDIF};
  {$IFDEF MACOSX}
  mainPath     : AnsiString;
  mainBundle   : CFBundleRef;
  tmpCFURLRef  : CFURLRef;
  tmpCFString  : CFStringRef;
  tmpPath      : array[ 0..8191 ] of Char;
  outItemHit   : SInt16;
  {$ENDIF}
{$IFEND}

// VECT
function cpfmin( a, b : cpFloat ) : cpFloat;
begin
  if a < b Then Result := a else Result := b;
end;

function cpfmax( a, b : cpFloat ) : cpFloat;
begin
  if a < b Then Result := b else Result := a;
end;

function cpv( x : cpFloat; y : cpFloat ) : cpVect;
begin
  Result.x := x;
  Result.y := y;
end;

function cpveql( v1 : cpVect; v2 : cpVect ) : cpBool;
begin
  Result := ( v1.x = v2.x ) and ( v1.y = v2.y );
end;

function cpvadd( v1 : cpVect; v2 : cpVect ) : cpVect;
begin
  Result := cpv( v1.x + v2.x, v1.y + v2.y );
end;

function cpvneg( v : cpVect ) : cpVect;
begin
  Result := cpv( -v.x, -v.y );
end;

function cpvsub( v1 : cpVect; v2 : cpVect ) : cpVect;
begin
  Result := cpv( v1.x - v2.x, v1.y - v2.y );
end;

function cpvmult( v : cpVect; s : cpFloat ) : cpVect;
begin
  Result := cpv( v.x * s, v.y * s );
end;

function cpvdot( v1 : cpVect; v2 : cpVect ) : cpFloat;
begin
  Result := v1.x * v2.x + v1.y * v2.y;
end;

function cpvcross( v1 : cpVect; v2 : cpVect ) : cpFloat;
begin
  Result := v1.x * v2.y - v1.y * v2.x;
end;

function cpvperp( v : cpVect ) : cpVect;
begin
  Result := cpv( -v.y, v.x );
end;

function cpvrperp( v : cpVect ) : cpVect;
begin
  Result := cpv( v.y, -v.x );
end;

function cpvproject( v1 : cpVect; v2 : cpVect ) : cpVect;
begin
  Result := cpvmult( v2, cpvdot( v1, v2 ) / cpvdot( v2, v2 ) );
end;

function cpvrotate( v1 : cpVect; v2 : cpVect ) : cpVect;
begin
  Result := cpv( v1.x * v2.x - v1.y * v2.y, v1.x * v2.y + v1.y * v2.x );
end;

function cpvunrotate( v1 : cpVect; v2 : cpVect ) : cpVect;
begin
  Result := cpv( v1.x * v2.x + v1.y * v2.y, v1.y * v2.x - v1.x * v2.y );
end;

function cpvlengthsq( v : cpVect ) : cpFloat;
begin
  Result := cpvdot( v, v );
end;

function cpvlerp( v1 : cpVect; v2 : cpVect; t : cpFloat ) : cpVect;
begin
  Result := cpvadd( cpvmult( v1, 1.0 - t ), cpvmult( v2, t ) );
end;

function cpvnormalize( v : cpVect ) : cpVect;
begin
  Result := cpvmult( v, 1.0 / cpvlength( v ) );
end;

function cpvnormalize_safe( v : cpVect ) : cpVect;
begin
  if ( v.x = 0.0 ) and ( v.y = 0.0 ) Then
    Result := cpvzero
  else
    Result := cpvnormalize( v );
end;

function cpvclamp( v : cpVect; len : cpFloat ) : cpVect;
begin
  if cpvdot( v, v ) > len * len Then
    Result := cpvmult( cpvnormalize( v ), len )
  else
    Result := v;
end;

function cpvlerpconst( v1 : cpVect; v2 : cpVect; d : cpFloat ) : cpVect;
begin
  Result := cpvadd( v1, cpvclamp( cpvsub( v2, v1 ), d ) );
end;

function cpvdist( v1 : cpVect; v2 : cpVect ) : cpFloat;
begin
  Result := cpvlength( cpvsub( v1, v2 ) );
end;

function cpvdistsq( v1 : cpVect; v2 : cpVect ) : cpFloat;
begin
  Result := cpvlengthsq( cpvsub( v1, v2 ) );
end;

function cpvnear( v1 : cpVect; v2 : cpVect; dist : cpFloat ) : cpBool;
begin
  Result := cpvdistsq( v1, v2 ) < dist * dist;
end;

// BB
function cpBBNew( l : cpFloat; b : cpFloat; r : cpFloat; t : cpFloat ) : cpBB;
begin
  Result.l := l;
  Result.b := b;
  Result.r := r;
  Result.t := t;
end;

function cpBBintersects( a : cpBB; b : cpBB ) : cpBool;
begin
  Result := ( a.l <= b.r ) and ( b.l <= a.r ) and ( a.b <= b.t ) and ( b.b <= a.t );
end;

function cpBBcontainsBB( bb : cpBB; other : cpBB ) : cpBool;
begin
  Result := ( bb.l < other.l ) and ( bb.r > other.r ) and ( bb.b < other.b ) and ( bb.t > other.t );
end;

function cpBBcontainsVect( bb : cpBB; v : cpVect ) : cpBool;
begin
  Result := ( bb.l < v.x ) and ( bb.r > v.x ) and ( bb.b < v.y ) and ( bb.t > v.y );
end;

function cpBBmerge( a : cpBB; b : cpBB ) : cpBB;
begin
  Result := cpBBNew( cpfmin( a.l, b.l ), cpfmin( a.b, b.b ), cpfmax( a.r, b.r ), cpfmax( a.t, b.t ) );
end;

function cpBBexpand( bb : cpBB; v : cpVect ) : cpBB;
begin
  Result := cpBBNew( cpfmin( bb.l, v.x ), cpfmin( bb.b, v.y ), cpfmax( bb.r, v.x ), cpfmax( bb.t, v.y ) );
end;

// ARBITER
procedure cpArbiterGetShapes( arb : PcpArbiter; a : PPcpShape; b : PPcpShape );
begin
  if arb.swappedColl Then
    begin
      a^ := arb.private_b;
      b^ := arb.private_a;
    end else
      begin
        a^ := arb.private_a;
        b^ := arb.private_b;
      end;
end;

procedure cpArbiterGetBodies( arb : PcpArbiter; a : PPcpBody; b : PPcpBody );
  var
    shape_a, shape_b : PcpShape;
begin
  cpArbiterGetShapes( arb, @shape_a, @shape_b );
  a^ := shape_a.body;
  b^ := shape_b.body;
end;

function cpArbiterIsFirstContact( arb : PcpArbiter ) : cpBool;
begin
  Result := arb.state = cpArbiterStateFirstColl;
end;

function cpArbiterGetNormal( arb : PcpArbiter; i : Integer ) : cpVect;
begin
  if arb.swappedColl Then
    Result := cpvneg( arb.contacts[ i ].n )
  else
    Result := arb.contacts[ i ].n;
end;

function cpArbiterGetPoint( arb : PcpArbiter; i : Integer ) : cpVect;
begin
  Result := arb.contacts[ i ].p;
end;

// SEGMENTSHAPE
function cpSegmentQueryHitPoint( start : cpVect; _end : cpVect; info : cpSegmentQueryInfo ) : cpVect;
begin
  Result := cpvlerp( start, _end, info.t );
end;

function cpSegmentQueryHitDist( start : cpVect; _end : cpVect; info : cpSegmentQueryInfo ) : cpFloat;
begin
  Result := cpvdist( start, _end ) * info.t;
end;

// POLYSHAPE
function cpPolyShapeValueOnAxis( poly : PcpPolyShape; n : cpVect; d : cpFloat ) : cpFloat;
  var
    verts : cpVectArray;
    min   : cpFloat;
    i     : Integer;
begin
  verts := poly.tVerts;
  min   := cpvdot( n, verts[ 0 ] );

  for i := 1 to poly.numVerts - 1 do
    min := cpfmin( min, cpvdot( n, verts[ i ] ) );

  Result := min - d;
end;

function cpPolyShapeContainsVert( poly : PcpPolyShape; v : cpVect ) : cpBool;
  var
    axes : cpPolyShapeAxisArray;
    i    : Integer;
    dist : cpFloat;
begin
  axes := poly.tAxes;

  for i := 0 to poly.numVerts - 1 do
    begin
      dist := cpvdot( axes[ i ].n, v ) - axes[ i ].d;
      if dist > 0.0 Then
        begin
          Result := cpFalse;
          exit;
        end;
    end;

  Result := cpTrue;
end;

function cpPolyShapeContainsVertPartial( poly : PcpPolyShape; v : cpVect; n : cpVect ) : cpBool;
  var
    axes : cpPolyShapeAxisArray;
    i    : Integer;
    dist : cpFloat;
begin
  axes := poly.tAxes;

  for i := 0 to poly.numVerts - 1 do
    begin
      if cpvdot( axes[ i ].n, n ) < 0.0 Then
        continue;
      dist := cpvdot( axes[ i ].n, v ) - axes[ i ].d;
      if dist > 0.0 Then
        begin
          Result := cpFalse;
          exit;
        end;
    end;

  Result := cpTrue;
end;

// BODY
function cpBodyIsSleeping( body : PcpBody ) : cpBool;
begin
  Result := Assigned( body.node.next );
end;

function cpBodyIsRogue( body : PcpBody ) : cpBool;
begin
  Result := not Assigned( body.space );
end;

// Convert body local to world coordinates
function cpBodyLocal2World( body : PcpBody; v : cpVect ) : cpVect;
begin
  Result := cpvadd( body.p, cpvrotate( v, body.rot ) );
end;

// Convert world to body local coordinates
function cpBodyWorld2Local( body : PcpBody; v : cpVect ) : cpVect;
begin
  Result := cpvunrotate( cpvsub( v, body.p ), body.rot );
end;

// Apply an impulse (in world coordinates) to the body at a point relative to the center of gravity (also in world coordinates).
procedure cpBodyApplyImpulse( body : PcpBody; j : cpVect; r : cpVect );
begin
  body.v := cpvadd( body.v, cpvmult( j, body.m_inv ) );
  body.w := body.w + body.i_inv * cpvcross( r, j );
end;

function cpBodyKineticEnergy( body : PcpBody ) : cpFloat;
  var
    vsq, wsq : cpFloat;
begin
  // Need to do some fudging to avoid NaNs
  vsq := cpvdot( body.v, body.v );
  wsq := body.w * body.w;
  if vsq > 0 Then
    vsq := vsq * body.m
  else
    vsq := 0;
  if wsq > 0 Then
    wsq := wsq * body.i
  else
    wsq := 0;
  Result := vsq + wsq;
end;

// CONSTRAINT
procedure cpConstraintActivateBodies( constraint : PcpConstraint );
  var
    a, b : PcpBody;
begin
  a := constraint.a;
  if Assigned( a ) Then
    cpBodyActivate( a );
  b := constraint.b;
  if Assigned( b ) Then
    cpBodyActivate( b );
end;

function cpConstraintGetImpulse( constraint : PcpConstraint ) : cpFloat;
begin
  Result := constraint.klass.getImpulse( constraint );
end;

// ADDITIONAL FUNCTIONS FOR ZenGL
procedure cpDrawShape( obj : pointer; data : pointer ); cdecl;
  var
    i     : Integer;
    shape : PcpShape;
begin
  shape := obj;
  case shape.klass._type of
    CP_CIRCLE_SHAPE:
      with PcpCircleShape( shape )^ do
        begin
          pr2d_Circle( tc.x, tc.y, r, PLongWord( data )^,{$IfDef OLD_METHODS} 255,{$EndIf} 32, PR2D_SMOOTH );
          pr2d_Line( tc.x, tc.y, tc.x + shape.body.rot.x * r, tc.y + shape.body.rot.y * r, PLongWord( data )^,{$IfDef OLD_METHODS} 255,{$EndIf} PR2D_SMOOTH );
        end;
    CP_SEGMENT_SHAPE:
      with PcpSegmentShape( shape )^ do
        begin
          pr2d_Line( ta.x, ta.y, tb.x, tb.y, PLongWord( data )^,{$IfDef OLD_METHODS} 255,{$EndIf} PR2D_SMOOTH );
        end;
    CP_POLY_SHAPE:
      with PcpPolyShape( shape )^ do
        begin
          for i := 0 to numVerts - 2 do
            pr2d_Line( tverts[ i ].x, tverts[ i ].y, tverts[ i + 1 ].x, tverts[ i + 1 ].y, PLongWord( data )^,{$IfDef OLD_METHODS} 255,{$EndIf} PR2D_SMOOTH );
          pr2d_Line( tverts[ numVerts - 1 ].x, tverts[ numVerts - 1 ].y, tverts[ 0 ].x, tverts[ 0 ].y, PLongWord( data )^,{$IfDef OLD_METHODS} 255,{$EndIf} PR2D_SMOOTH );
        end;
  end;
end;

procedure cpDrawCollision( ptr : pointer; data : pointer ); cdecl;
  var
    i : integer;
    a : PcpArbiter;
    v : cpVect;
begin
  a := ptr;
  for i := 0 to a.numContacts - 1 do
    begin
      v := a.contacts[ i ].p;
      pr2d_Circle( v.x, v.y, 4, PLongWord( data )^,{$IfDef OLD_METHODS} 255,{$EndIf} 8, PR2D_SMOOTH or PR2D_FILL );
    end;
end;

procedure cpDrawSpace;
begin
  if not Assigned( space ) Then exit;

  cpSpaceHashEach( space.staticShapes, cpDrawShape, @cpColorStatic );
  cpSpaceHashEach( space.activeShapes, cpDrawShape, @cpColorActive );

  if DrawCollisions Then
    cpArrayEach( space.arbiters, cpDrawCollision, @cpColorCollision );
end;

// Это компиляция внутри программы?
{$IF ( not DEFINED( USE_CHIPMUNK_STATIC ) ) and ( not DEFINED( USE_CHIPMUNK_LINK ) )}
function cpLoad( LibraryName : AnsiString; Error : Boolean = TRUE ) : Boolean;
begin
  Result := FALSE;
  {$IFDEF UNIX}
  cpLib := dlopen( PAnsiChar( './' + LibraryName ), $001 );
  if not Assigned( cpLib ) Then
  {$ENDIF}
  {$IFDEF MACOSX}
  mainBundle  := CFBundleGetMainBundle;
  tmpCFURLRef := CFBundleCopyBundleURL( mainBundle );
  tmpCFString := CFURLCopyFileSystemPath( tmpCFURLRef, kCFURLPOSIXPathStyle );
  CFStringGetFileSystemRepresentation( tmpCFString, @tmpPath[ 0 ], 8192 );
  mainPath    := tmpPath + '/Contents/';
  LibraryName := mainPath + 'Frameworks/' + LibraryName;
  {$ENDIF}
  cpLib := dlopen( PAnsiChar( LibraryName ) {$IFDEF UNIX}, $001 {$ENDIF} );

  if cpLib <> {$IFDEF UNIX} nil {$ENDIF} {$IFDEF WINDOWS} 0 {$ENDIF} Then
    begin
      Result := TRUE;

      cpInitChipmunk := dlsym( cpLib, 'cpInitChipmunk' );
      cpMomentForCircle := dlsym( cpLib, 'cpMomentForCircle' );
      cpMomentForSegment := dlsym( cpLib, 'cpMomentForSegment' );
      cpMomentForPoly := dlsym( cpLib, 'cpMomentForPoly' );
      cpMomentForBox := dlsym( cpLib, 'cpMomentForBox' );

      cpvlength := dlsym( cpLib, 'cpvlength' );
      cpvslerp := dlsym( cpLib, 'cpvslerp' );
      cpvslerpconst := dlsym( cpLib, 'cpvslerpconst' );
      cpvforangle := dlsym( cpLib, 'cpvforangle' );
      cpvtoangle := dlsym( cpLib, 'cpvtoangle' );

      cpBBClampVect := dlsym( cpLib, 'cpBBClampVect' );
      cpBBWrapVect := dlsym( cpLib, 'cpBBWrapVect' );

      cpArrayAlloc := dlsym( cpLib, 'cpArrayAlloc' );
      cpArrayInit := dlsym( cpLib, 'cpArrayInit' );
      cpArrayNew := dlsym( cpLib, 'cpArrayNew' );
      cpArrayDestroy := dlsym( cpLib, 'cpArrayDestroy' );
      cpArrayFree := dlsym( cpLib, 'cpArrayFree' );
      cpArrayClear := dlsym( cpLib, 'cpArrayClear' );
      cpArrayPush := dlsym( cpLib, 'cpArrayPush' );
      cpArrayPop := dlsym( cpLib, 'cpArrayPop' );
      cpArrayDeleteIndex := dlsym( cpLib, 'cpArrayDeleteIndex' );
      cpArrayDeleteObj := dlsym( cpLib, 'cpArrayDeleteObj' );
      cpArrayAppend := dlsym( cpLib, 'cpArrayAppend' );
      cpArrayEach := dlsym( cpLib, 'cpArrayEach' );
      cpArrayContains := dlsym( cpLib, 'cpArrayContains' );

      cpContactInit := dlsym( cpLib, 'cpContactInit' );
      cpArbiterInit := dlsym( cpLib, 'cpArbiterInit' );
      cpArbiterUpdate := dlsym( cpLib, 'cpArbiterUpdate' );
      cpArbiterPreStep := dlsym( cpLib, 'cpArbiterPreStep' );
      cpArbiterApplyCachedImpulse := dlsym( cpLib, 'cpArbiterApplyCachedImpulse' );
      cpArbiterApplyImpulse := dlsym( cpLib, 'cpArbiterApplyImpulse' );
      cpArbiterTotalImpulse := dlsym( cpLib, 'cpArbiterTotalImpulse' );
      cpArbiterTotalImpulseWithFriction := dlsym( cpLib, 'cpArbiterTotalImpulseWithFriction' );
      cpArbiterIgnore := dlsym( cpLib, 'cpArbiterIgnore' );

      cpShapeInit := dlsym( cpLib, 'cpShapeInit' );
      cpShapeDestroy := dlsym( cpLib, 'cpShapeDestroy' );
      cpShapeFree := dlsym( cpLib, 'cpShapeFree' );
      cpShapeCacheBB := dlsym( cpLib, 'cpShapeCacheBB' );
      cpShapePointQuery := dlsym( cpLib, 'cpShapePointQuery' );

      cpCircleShapeAlloc := dlsym( cpLib, 'cpCircleShapeAlloc' );
      cpCircleShapeInit := dlsym( cpLib, 'cpCircleShapeInit' );
      cpCircleShapeNew := dlsym( cpLib, 'cpCircleShapeNew' );

      cpSegmentShapeAlloc := dlsym( cpLib, 'cpSegmentShapeAlloc' );
      cpSegmentShapeInit := dlsym( cpLib, 'cpSegmentShapeInit' );
      cpSegmentShapeNew := dlsym( cpLib, 'cpSegmentShapeNew' );

      cpResetShapeIdCounter := dlsym( cpLib, 'cpResetShapeIdCounter' );
      cpShapeSegmentQuery := dlsym( cpLib, 'cpShapeSegmentQuery' );

      cpPolyShapeAlloc := dlsym( cpLib, 'cpPolyShapeAlloc' );
      cpPolyShapeInit := dlsym( cpLib, 'cpPolyShapeInit' );
      cpPolyShapeNew := dlsym( cpLib, 'cpPolyShapeNew' );
      cpBoxShapeInit := dlsym( cpLib, 'cpBoxShapeInit' );
      cpBoxShapeNew := dlsym( cpLib, 'cpBoxShapeNew' );
      cpPolyValidate := dlsym( cpLib, 'cpPolyValidate' );
      cpPolyShapeGetNumVerts := dlsym( cpLib, 'cpPolyShapeGetNumVerts' );
      cpPolyShapeGetVert := dlsym( cpLib, 'cpPolyShapeGetVert' );

      cpBodyAlloc :=  dlsym( cpLib, 'cpBodyAlloc' );
      cpBodyInit := dlsym( cpLib, 'cpBodyInit' );
      cpBodyNew := dlsym( cpLib, 'cpBodyNew' );
      cpBodyDestroy := dlsym( cpLib, 'cpBodyDestroy' );
      cpBodyFree := dlsym( cpLib, 'cpBodyFree' );
      cpBodyActivate := dlsym( cpLib, 'cpBodyActivate' );
      cpBodySleep := dlsym( cpLib, 'cpBodySleep' );
      cpBodySetMass := dlsym( cpLib, 'cpBodySetMass' );
      cpBodySetMoment := dlsym( cpLib, 'cpBodySetMoment' );
      cpBodySetAngle := dlsym( cpLib, 'cpBodySetAngle' );
      cpBodySlew := dlsym( cpLib, 'cpBodySlew' );
      cpBodyUpdateVelocity := dlsym( cpLib, 'cpBodyUpdateVelocity' );
      cpBodyUpdatePosition := dlsym( cpLib, 'cpBodyUpdatePosition' );
      cpBodyResetForces := dlsym( cpLib, 'cpBodyResetForces' );
      cpBodyApplyForce := dlsym( cpLib, 'cpBodyApplyForce' );
      cpApplyDampedSpring := dlsym( cpLib, 'cpApplyDampedSpring' );

      cpConstraintDestroy := dlsym( cpLib, 'cpConstraintDestroy' );
      cpConstraintFree := dlsym( cpLib, 'cpConstraintFree' );
      cpPinJointGetClass := dlsym( cpLib, 'cpPinJointGetClass' );
      cpPinJointAlloc := dlsym( cpLib, 'cpPinJointAlloc' );
      cpPinJointInit := dlsym( cpLib, 'cpPinJointInit' );
      cpPinJointNew := dlsym( cpLib, 'cpPinJointNew' );
      cpSlideJointGetClass := dlsym( cpLib, 'cpSlideJointGetClass' );
      cpSlideJointAlloc := dlsym( cpLib, 'cpSlideJointAlloc' );
      cpSlideJointInit := dlsym( cpLib, 'cpSlideJointInit' );
      cpSlideJointNew := dlsym( cpLib, 'cpSlideJointNew' );
      cpPivotJointGetClass := dlsym( cpLib, 'cpPivotJointGetClass' );
      cpPivotJointAlloc := dlsym( cpLib, 'cpPivotJointAlloc' );
      cpPivotJointInit := dlsym( cpLib, 'cpPivotJointInit' );
      cpPivotJointNew := dlsym( cpLib, 'cpPivotJointNew' );
      cpPivotJointNew2 := dlsym( cpLib, 'cpPivotJointNew2' );
      cpGrooveJointGetClass := dlsym( cpLib, 'cpGrooveJointGetClass' );
      cpGrooveJointAlloc := dlsym( cpLib, 'cpGrooveJointAlloc' );
      cpGrooveJointInit := dlsym( cpLib, 'cpGrooveJointInit' );
      cpGrooveJointNew := dlsym( cpLib, 'cpGrooveJointNew' );
      cpGrooveJointSetGrooveA := dlsym( cpLib, 'cpGrooveJointSetGrooveA' );
      cpGrooveJointSetGrooveB := dlsym( cpLib, 'cpGrooveJointSetGrooveB' );
      cpDampedSpringGetClass := dlsym( cpLib, 'cpDampedSpringGetClass' );
      cpDampedSpringAlloc := dlsym( cpLib, 'cpDampedSpringAlloc' );
      cpDampedSpringInit := dlsym( cpLib, 'cpDampedSpringInit' );
      cpDampedSpringNew := dlsym( cpLib, 'cpDampedSpringNew' );
      cpDampedRotarySpringGetClass := dlsym( cpLib, 'cpDampedRotarySpringGetClass' );
      cpDampedRotarySpringAlloc := dlsym( cpLib, 'cpDampedRotarySpringAlloc' );
      cpDampedRotarySpringInit := dlsym( cpLib, 'cpDampedRotarySpringInit' );
      cpDampedRotarySpringNew := dlsym( cpLib, 'cpDampedRotarySpringNew' );
      cpRotaryLimitJointGetClass := dlsym( cpLib, 'cpRotaryLimitJointGetClass' );
      cpRotaryLimitJointAlloc := dlsym( cpLib, 'cpRotaryLimitJointAlloc' );
      cpRotaryLimitJointInit := dlsym( cpLib, 'cpRotaryLimitJointInit' );
      cpRotaryLimitJointNew := dlsym( cpLib, 'cpRotaryLimitJointNew' );
      cpRatchetJointGetClass := dlsym( cpLib, 'cpRatchetJointGetClass' );
      cpRatchetJointAlloc := dlsym( cpLib, 'cpRatchetJointAlloc' );
      cpRatchetJointInit := dlsym( cpLib, 'cpRatchetJointInit' );
      cpRatchetJointNew := dlsym( cpLib, 'cpRatchetJointNew' );
      cpGearJointGetClass := dlsym( cpLib, 'cpGearJointGetClass' );
      cpGearJointAlloc := dlsym( cpLib, 'cpGearJointAlloc' );
      cpGearJointInit := dlsym( cpLib, 'cpGearJointInit' );
      cpGearJointNew := dlsym( cpLib, 'cpGearJointNew' );
      cpSimpleMotorGetClass := dlsym( cpLib, 'cpSimpleMotorGetClass' );
      cpSimpleMotorAlloc := dlsym( cpLib, 'cpSimpleMotorAlloc' );
      cpSimpleMotorInit := dlsym( cpLib, 'cpSimpleMotorInit' );
      cpSimpleMotorNew := dlsym( cpLib, 'cpSimpleMotorNew' );

      cpSpaceAlloc := dlsym( cpLib, 'cpSpaceAlloc' );
      cpSpaceInit := dlsym( cpLib, 'cpSpaceInit' );
      cpSpaceNew := dlsym( cpLib, 'cpSpaceNew' );
      cpSpaceDestroy := dlsym( cpLib, 'cpSpaceDestroy' );
      cpSpaceFree := dlsym( cpLib, 'cpSpaceFree' );
      cpSpaceFreeChildren := dlsym( cpLib, 'cpSpaceFreeChildren' );
      cpSpaceSetDefaultCollisionHandler := dlsym( cpLib, 'cpSpaceSetDefaultCollisionHandler' );
      cpSpaceAddCollisionHandler := dlsym( cpLib, 'cpSpaceAddCollisionHandler' );
      cpSpaceRemoveCollisionHandler := dlsym( cpLib, 'cpSpaceRemoveCollisionHandler' );
      cpSpaceAddShape := dlsym( cpLib, 'cpSpaceAddShape' );
      cpSpaceAddStaticShape := dlsym( cpLib, 'cpSpaceAddStaticShape' );
      cpSpaceAddBody := dlsym( cpLib, 'cpSpaceAddBody' );
      cpSpaceAddConstraint := dlsym( cpLib, 'cpSpaceAddConstraint' );
      cpSpaceRemoveShape := dlsym( cpLib, 'cpSpaceRemoveShape' );
      cpSpaceRemoveStaticShape := dlsym( cpLib, 'cpSpaceRemoveStaticShape' );
      cpSpaceRemoveBody := dlsym( cpLib, 'cpSpaceRemoveBody' );
      cpSpaceRemoveConstraint := dlsym( cpLib, 'cpSpaceRemoveConstraint' );
      cpSpaceAddPostStepCallback := dlsym( cpLib, 'cpSpaceAddPostStepCallback' );
      cpSpacePointQuery := dlsym( cpLib, 'cpSpacePointQuery' );
      cpSpacePointQueryFirst := dlsym( cpLib, 'cpSpacePointQueryFirst' );
      cpSpaceSegmentQuery := dlsym( cpLib, 'cpSpaceSegmentQuery' );
      cpSpaceSegmentQueryFirst := dlsym( cpLib, 'cpSpaceSegmentQueryFirst' );
      cpSpaceBBQuery := dlsym( cpLib, 'cpSpaceBBQuery' );
      cpSpaceEachBody := dlsym( cpLib, 'cpSpaceEachBody' );
      cpSpaceResizeStaticHash := dlsym( cpLib, 'cpSpaceResizeStaticHash' );
      cpSpaceResizeActiveHash := dlsym( cpLib, 'cpSpaceResizeActiveHash' );
      cpSpaceRehashStatic := dlsym( cpLib, 'cpSpaceRehashStatic' );
      cpSpaceRehashShape := dlsym( cpLib, 'cpSpaceRehashShape' );
      cpSpaceStep := dlsym( cpLib, 'cpSpaceStep' );

      cpHashSetDestroy := dlsym( cpLib, 'cpHashSetDestroy' );
      cpHashSetFree := dlsym( cpLib, 'cpHashSetFree' );
      cpHashSetAlloc := dlsym( cpLib, 'cpHashSetAlloc' );
      cpHashSetInit := dlsym( cpLib, 'cpHashSetInit' );
      cpHashSetNew := dlsym( cpLib, 'cpHashSetNew' );
      cpHashSetInsert := dlsym( cpLib, 'cpHashSetInsert' );
      cpHashSetRemove := dlsym( cpLib, 'cpHashSetRemove' );
      cpHashSetFind := dlsym( cpLib, 'cpHashSetFind' );
      cpHashSetEach := dlsym( cpLib, 'cpHashSetEach' );
      cpHashSetFilter := dlsym( cpLib, 'cpHashSetFilter' );

      cpSpaceHashAlloc := dlsym( cpLib, 'cpSpaceHashAlloc' );
      cpSpaceHashInit := dlsym( cpLib, 'cpSpaceHashInit' );
      cpSpaceHashNew := dlsym( cpLib, 'cpSpaceHashNew' );
      cpSpaceHashDestroy := dlsym( cpLib, 'cpSpaceHashDestroy' );
      cpSpaceHashFree := dlsym( cpLib, 'cpSpaceHashFree' );
      cpSpaceHashResize := dlsym( cpLib, 'cpSpaceHashResize' );
      cpSpaceHashInsert := dlsym( cpLib, 'cpSpaceHashInsert' );
      cpSpaceHashRemove := dlsym( cpLib, 'cpSpaceHashRemove' );
      cpSpaceHashEach := dlsym( cpLib, 'cpSpaceHashEach' );
      cpSpaceHashRehash := dlsym( cpLib, 'cpSpaceHashRehash' );
      cpSpaceHashRehashObject := dlsym( cpLib, 'cpSpaceHashRehashObject' );
      cpSpaceHashPointQuery := dlsym( cpLib, 'cpSpaceHashPointQuery' );
      cpSpaceHashQuery := dlsym( cpLib, 'cpSpaceHashQuery' );
      cpSpaceHashQueryInsert := dlsym( cpLib, 'cpSpaceHashQueryInsert' );
      cpSpaceHashQueryRehash := dlsym( cpLib, 'cpSpaceHashQueryRehash' );
      cpSpaceHashSegmentQuery := dlsym( cpLib, 'cpSpaceHashSegmentQuery' );

      cpCollideShapes := dlsym( cpLib, 'cpCollideShapes' );
    end else
      if Error Then
        begin
          {$IFDEF UNIX}
          WriteLn( 'Error while loading Chipmunk' );
          {$ENDIF}
          {$IFDEF WINDOWS}
          MessageBoxA( 0, 'Error while loading Chipmunk', 'Error', $00000010 );
          {$ENDIF}
          {$IFDEF MACOSX}
          StandardAlert( kAlertNoteAlert, 'Error', 'Error while loading Chipmunk', nil, outItemHit );
          {$ENDIF}
        end;
end;

procedure cpFree;
begin
  dlclose( cpLib );
end;
{$IFEND}

end.
