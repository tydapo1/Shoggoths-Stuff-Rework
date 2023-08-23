function init()
	self.movementParameters = config.getParameter("movementParameters", {})	
	script.setUpdateDelta(3)
end

function update(dt)	
	mcontroller.controlParameters(self.movementParameters)
	animator.setFlipped(mcontroller.facingDirection() == -1)
end

function uninit()
  
end
