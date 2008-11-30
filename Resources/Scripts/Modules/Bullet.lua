class "Bullet" ("PhysicsObject")

function Bullet:initialize(baseMass, location, speed, angle, target)
    self._target = target
    self._location = location
    self._velocity = { x = speed * math.cos(angle), y = speed * math.sin(angle) }
    self._top_speed = speed
    self._angle = angle
    self._angular_velocity = 0.0
    self_top_angular_velocity = 3.0
    self._mass = baseMass
    self._drag = 0.0
    self._rotational_drag = 0.0
end

function Bullet:target ()
    return self._target
end

function Bullet:set_target ( newTarget )
    self._target = newTarget
end
