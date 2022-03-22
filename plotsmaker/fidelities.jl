using PGFPlotsX
using DelimitedFiles 
using Colors
color = (
    blue = colorant"#0547d5",
    red = colorant"#dd2700",
    green = colorant"#05ae41",
    yellow  = colorant"#ffa550",
    black = colorant"#000000",
)
dashes = (
	singledash =  "on 5pt off 3 pt",
	point = "on 1pt off 1pt",
	solid = "on 10pt off 0pt",
        pointdash = "on 5pt off 1pt on 1pt off 1pt ",
	shortherdash = "on 3pt off 1pt",
)
width = [
	 "1.91pt", 	
	 "1.74pt", 	
	 "1.53pt",
	 "1.24pt",
	 "1.14pt"
	 ]
mutable struct MyProt 
	order::Int
	ω::Int
	k::Int
end
mutable struct MyStyle
	dash::String
	color
end
function readdata(pr::MyProt)
	"""
	Take the order and the omega of each protocol and gives back the corresponding curve and curvature
	"""	
	data = readdlm("data/order$(pr.order)x_$(pr.ω).dat")
	return data
end
##
function fid(order, ω)
	"""
	Take the omega and the order of the protocol as the input and read the data file for the fidelity.
	Then produces a Coordinates type and plots it adding the relative legend
	"""	
	data = readdlm("data/order$(order)x_$(ω).dat")
	data = unique(data, dims = 1)
	coordinates = Coordinates(data[:,1], data[:,2])
	plotting = @pgf Plot(
			     {color = color[order],
			      line_width = width[order],
			      dash_pattern = dashses[order+1]},
	       coordinates)
	legend = @pgf LegendEntry("\$\\Gamma_{$order}\$ ")		 
	return [plotting, legend]	
end
k0 = 300
omega = 7 
function axes(ω)
	"""
	produces the axis types to then create the group plot
	"""	
	ax = @pgf Axis({
		       xlabel = raw"$k_0 R$",
		       ylabel = "F",
		       ylabel_style = {"rotate = -90", "at={(-0.05,0.9)}"},
		       x_tick_label_style = raw"/pgf/number format/1000 sep = {}",
		       legend_style = {"at={(.25,.5)}","draw=none"},
		       #title = "\$ \\omega = $ω\$", 
	       })
	for order in 1:4 
		push!(ax, fid(order, ω)[1])
	end
	return ax
end

"""
Creating the group plot type to store the fidelities for different omegas
"""	

gp = @pgf GroupPlot(
		    {
		     group_style = {group_size = "3 by 1"}
		     },
		    )
for ω in [3,5,7]
	push!(gp, axes(ω))
end
pgfsave( "../gfx/fidelities.pdf", gp)
##
function curvefromtop(order, ω, k)
	"""
	Creates the image to produce the curve as seen from the top 	
	"""	
	y = Array{Float64}(undef, 10005,2)
	data = read!("/home/manuel/Desktop/PhD/Waveguides/Calculation/Fixed_trapping/Order$order/curve_order$(order)_$(ω)_$(k).bin",y)
	curve = Coordinates(data[6:10:end,1],data[6:10:end,2])
	figure = @pgf Plot(
			  {
			   color = color[order+1], 
			   line_width = width[order+1],
			   dash_pattern = dashses[order+1],
			   },
			  curve)
	legend = @pgf LegendEntry("\$\\Gamma_{$order}\$ ")		 
	return [figure,legend]
end

curveax = @pgf Axis({
		name = "curveax",	 
		xlabel = raw"$x/R$",
		ylabel = raw"$y/R$",
		ylabel_style = "rotate = -90",
		legend_style = {"at={(.25,1)}","draw=none"},
	       })
for order in 0:2 
	push!(curveax, curvefromtop(order, omega,k0)[1])
end
pgfsave( "../gfx/curves.pdf", curveax)

##
function curvature(order, ω, k)
	"""
	Produces the curvature of the corresponding ω and order 
	"""	
	data = readdlm("/home/manuel/Desktop/PhD/Waveguides/Calculation/Fixed_trapping/Order$order/curvature_order$(order)_$(ω)_$(k).dat")
	curve = Coordinates(data[:,1],data[:,2])
	figure = @pgf Plot(
			  {
			   color = color[order], 
			   line_width = width[order],
			   dash_pattern = dashses[order+1],
			   },
			  curve)
	legend = @pgf LegendEntry("\$\\Gamma_{$order}\$ ")		 
	return [figure,legend]
end
curvatureax = @pgf Axis({
		xlabel = raw"$s/R$",
		ylabel = raw"$\gamma R$",
		ylabel_style = "rotate = -90",
		legend_style = {"at={(.25,1)}","draw=none"},
	       })
for order in 1:2 
	push!(curvatureax, curvature(order, omega,k0)[1])
end
pgfsave( "../gfx/curvatures.pdf", curvatureax )
