using ArgParse # Might switch to some other package
using LeakageAssessment
using LeakageAssessment: loaddata

function parse_commandline()
    s = ArgParseSettings()
    @add_arg_table! s begin
        #"--output"
        #    help = "file name for SNR.png result"
        "--ppc"
            arg_type = Int
            default  = 0
            help     = "points per clock"
        "--threshold"
            arg_type = Float32
            default  = 4.5
            help     = "TVLA leakage threshold"
        "--single"
            action   = :store_true
            help     = "run TVLA only once, not splitting into 2 subsets"
        "traces1"
            help     = "trace group 1 (traces.h5 file)"
            required = true
        "traces2"
            help     = "trace group 2 (traces.h5 file)"
            required = true
    end
    return parse_args(s)
end

function main()
    # parse arguments
    args = parse_commandline()

    # load data
    traces1 = loaddata(args["traces1"])
    traces2 = loaddata(args["traces2"])

    # plot TVLA
    if args["single"]
        print("plotting TVLA result    ")
        plotTtest(traces1, traces2; block=true, ppc=args["ppc"], threshold=args["threshold"])
    else
        p = TVLA(traces1, traces2; ppc=args["ppc"], threshold=args["threshold"])
        display(p); print("Press Enter to continue..."); readline()
    end
end


if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
