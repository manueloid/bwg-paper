using PGFPlotsX
ξ(t) = sin(t)
η(t) = 1 - cos(t)
steps = 20
trange = range(0, stop = pi/2, length = steps)	
xpost = range(1.0, stop = 1, length = steps)
ypost = range(1, stop = 1.2, length = steps)
xpre =  range(-0.2, stop = 0.0, length = steps)
ypre =  range(0.0, stop = 0.0, length = steps)
x = vcat(xpre, ξ.(trange), xpost)
y = vcat(ypre, η.(trange), ypost)
tab = Table(x, y)
t0 = pi/2.5
tx(t) = cos(t); ty(t) = sin(t)
nx(t) = -sin(t); ny(t) = cos(t)
u0 = .7
xp(u, t) = ξ(t) + u*nx(t)
yp(u, t) = η(t) + u*ny(t)
xc = xp(0,t0); yc = yp(0,t0);
x0 = xp(u0,t0); y0 = yp(u0,t0);
point = Coordinates([xp(u0, t0)], [yp(u0, t0)])
td = @pgf Axis(
    {
        ticks = "none",
        axis_x_line = "middle",
        axis_y_line = "middle",
        xlabel = "x",
        ylabel = "y",
        ymin = "-0.1",
        xmax = "1.1",
	xmin = "-0.2",
	axis_equal,
    },
    Plot({color = "black", mark = "*", mark_size = "1.5pt", opacity = ".4"}, point),
)
arrcurv = @pgf Plot(
    { quiver = {u = "\\thisrow{u}", v = "\\thisrow{v}"}, "-stealth",
    },
    Table(x = [0], y = [0], u = [xc], v = [yc]),
)
gamma = "\\node[anchor = south, rotate = 35] at ($(xc/2), $(yc/2)) {\$\\vec{\\mathbf{\\Gamma}}(s_P)\$};"
curve = @pgf Plot({color = "black", mark = " ", "very thick", "dashed"}, tab)
vline = @pgf Plot({"dash pattern = on 1pt"}, Coordinates([x0, x0], [0, y0]))
hline = @pgf Plot({"dash pattern = on 1pt"}, Coordinates([0, x0], [y0, y0]))
connectliner = @pgf Plot({"dashed"}, Coordinates([x0,xc], [y0, yc]))
push!(td, hline,connectliner, vline, curve, arrcurv,gamma)

ϵ =.01

annotatept = "\\node[anchor = south ] at ($(x0+ϵ), $(y0 + ϵ)) {P};"
annotateptx = "\\node[anchor = north ] at ($(x0), -0.0) {\$x_{P}\$};"
annotatepty = "\\node[anchor = east ] at (-0.0, $(y0)) {\$y_{P}\$};"
annotaten  ="\\node[anchor = east ] at (-0.0, $(y0)) {\$y_{P}\$};"
push!(td, annotatept, annotateptx, annotatepty)

magn = .4;
tframe = @pgf Plot(
    { quiver = {u = "\\thisrow{u}", v = "\\thisrow{v}"}, "-stealth"},
    Table(x = [xc], y = [yc], u = [magn * tx(t0)], v =	 [magn * ty(t0)]),
)
nframe = @pgf Plot(
    { quiver = {u = "\\thisrow{u}", v = "\\thisrow{v}"}, "-stealth"},
    Table(x = [xc], y = [yc], u = [magn * nx(t0)], v =	 [magn * ny(t0)]),
)
npos = [xp(magn/2, t0), yp(magn/2,t0)]
annotaten  ="\\node[anchor = north ,rotate = -15] at ($(npos[1]), $(npos[2])) {\$\\mathbf{\\hat{n}}\$};"
upos = [xp(1.2magn, t0), yp(1.2magn,t0)]
annotateu  ="\\node[anchor = south ,rotate = -15] at ($(upos[1]), $(upos[2])) {\$u_P\$};"
tpos = [xc + tx(t0) * magn/2, yc + ty(t0) * magn/2]
annotatet  ="\\node[anchor = west ,rotate = -15] at ($(tpos[1]), $(tpos[2])) {\$\\mathbf{\\hat{t}}\$};"
push!(td,tframe, nframe, annotaten, annotatet, annotateu)
pgfsave("../gfx/frenet.pdf", td)
