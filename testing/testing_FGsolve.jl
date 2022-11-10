using ImagesDLT, Images, Plots

dlt = ImagesDLT

currentdir = @__DIR__

cd(currentdir)


mat = [ 0 0.5 0.5 320 530 219 597
        0 0 0.5 664 631 518 687
        0.5 0.5 0.5 571 469 523 530
        0.5 0 0.5 918 578 825 621
        0 0.5 0 265 935 190 997
        0 0 0 619 1034 502 1093]

xvec = mat[:,1]
yvec = mat[:,2]
zvec = mat[:,3]
ulvec = mat[:,4]
vlvec = mat[:,5]
urvec = mat[:,6]
vrvec = mat[:,7]

L = dlt.FGsolve(xvec, yvec, zvec, ulvec, vlvec)
R = dlt.FGsolve(xvec, yvec, zvec, urvec, vrvec)

#=
L = {475.0 −718.5 126.9 619.1 −143.8 −233.0 −767.2 1033.7 −0.053 −0.039 0.057}
R = {629.6 −622.6 77.8 502.0 −147.4 −184.2 −750.6 1092.9 −0.014 0.0076 0.089}

=#