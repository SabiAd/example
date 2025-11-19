version 1.0

task Count_Ns {
    input {
        File fasta
    }

    command <<<
        echo "Running Count_Ns task"
        echo "Input FASTA: ~{fasta}"
        ls -lh $(dirname ~{fasta})
        /home/user/miniconda3/bin/seqtk gap ~{fasta} | awk '{s+=$2} END {print s}' > countNS.txt
        echo "Done!"
    >>>

    output {
        Int n_count = read_int("countNS.txt")
    }
}

workflow CountNs_slow {
    input {
        File fa
    }

    call Count_Ns {
        input:
            fasta = fa
    }

    output {
        Int total_Ns = Count_Ns.n_count
    }

    runtime {
        docker: "biocontainers/seqtk:v1.3-4-deb_cv1"
    }
}
