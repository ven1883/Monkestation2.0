/obj/machinery/camera/proc/change_camnet(datum/cameranet/newnet)
	if(newnet && istype(newnet))
		camnet.cameras -= src
		camnet.removeCamera(src)
		camnet = newnet
		camnet.cameras += src
		camnet.addCamera(src)
