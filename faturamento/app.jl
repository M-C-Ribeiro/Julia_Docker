module App

using GenieFramework
@genietools
using Stipple
using StippleUI
using StipplePlotly
using SQLite
using DataFrames

function mean(x)
    sum(x) / length(x)
end

@app begin

    const ALL = "ALL"
    const db = SQLite.DB(joinpath("data","../src/vendas.sqlite")) # conexao com banco

    function movie_data(column)
        result = DBInterface.execute(db, "select distinct(`Branch`) from vendas") |> DataFrame
        c = String[]
        for entry in result[!,Symbol(column)]
          for e in split(entry, ',')
            push!(c, strip(e))
          end
        end
        pushfirst!(c |> unique! |> sort!, ALL)
    end

    function vendas(filters::Vector{<:String} = String[])
        query = "select * from vendas where 1"
        for f in filters
          isempty(f) && continue
          query *= " and $f"
        end
        
        DBInterface.execute(db, query) |> DataFrame
    end

    function selected_venda()
        result = DBInterface.execute(db, "select * from vendas order by random() limit 1") |> DataFrame
        data = Dict{String,Any}()
        for col in names(result)
          val = result[1,col]
          data[col] = isa(val, Missing) ? "" : val
        end
        data
    end
      
    function validvalue(filters::Vector{<:String})
        [endswith(f, "'%$(ALL)%'") || endswith(f, "'%%'") ? "" : f for f in filters]
    end
      
    function plot_data()
        PlotData( x = (years_range.start:years_range.stop),
                  y = (1:10),
                  name = "Vendas por ano",
                  plot = StipplePlotly.Charts.PLOT_TYPE_SCATTER
                )
    end
      
    function plot_data(df)
        [
          PlotData(
            x = df.Runtime,
            y = df.Vendas,
            name = "numero de vendas",
            text = string.(df.Title, " (", df.Year, ")"),
            mode = "markers",
            plot = StipplePlotly.Charts.PLOT_TYPE_SCATTER,
          ),
          PlotData(
            x = df.Runtime,
            y = (x->length(findall(',', x))).(df.Cast),
            name = "number of casts",
            text = string.(df.Title, " (", df.Year, ")"),
            mode = "markers",
            plot = StipplePlotly.Charts.PLOT_TYPE_SCATTER
          )
        ]
    end
      
    function plot_layout(xtitle, ytitle)
        PlotLayout(
          xaxis = [PlotLayoutAxis(title = xtitle)],
          yaxis = [PlotLayoutAxis(xy = "y", title = ytitle)]
        )
    end

    @reactive mutable struct App :: ReactiveModel
        @in filter_filial::R{String} = ALL
        @in filiais::Vector{<:String} = movie_data("Branch")
        @out vendas::R{DataTable} = DataTable(vendas(), table_options)
        vendas_pagination::DataTablePagination = DataTablePagination(rows_per_page=50)
        vendas_selection::R{DataTableSelection} = DataTableSelection()
        @out selected_venda::R{Dict} = selected_venda()
        data::R{Vector{PlotData}} = [plot_data()]
        layout::R{PlotLayout} = PlotLayout(plot_bgcolor = "#fff")
        @mixin data::PlotlyEvents
    end
      
    Stipple.js_mounted(::App) = watchplots()
      
    function handlers(model<:App)
        onany(model.filter_filial, model.isready) do fo
            model.isprocessing[] = true
            @in model.vendas[] = DataTable(String[
              "`Filiais` >= '$(fo)'"
            ] |> validvalue |> vendas, table_options)
            @out model.data[] = plot_data(model.movies.data)
            model.layout[] = plot_layout("Runtime [min]", "Number")
            model.isprocessing[] = false
        end
    
        on(model.data_selected) do data
          selectrows!(model, :movies, getindex.(data["points"], "pointIndex") .+ 1)
        end
    
        on(model.data_hover) do data
          isempty(data) && return
          n = data["points"][1]["pointIndex"] + 1
          model.selected_venda[] = rowselection(model.movies[], n)[1]
        end
    
        on(model.vendas_selection) do selection
            ii = union(getindex.(selection, "__id")) .- 1
            for n in 1:length(model.data[])
              model["data[$n-1].selectedpoints"] = isempty(ii) ? nothing : ii
            end
            notify(model, js"data")
        end
    
        model
        end


    @in N = 0
    @out msg = "The average is 0."
    @private result = 0.0

    @onchange N begin
        result = mean(rand(N))
        msg = "The average is $result."
    end
end

@page("/", "app.jl.html")
end
