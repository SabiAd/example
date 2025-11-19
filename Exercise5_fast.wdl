version 1.0

task SplitFasta {
    input {
        File fasta
    }

    command <<<
        set -euo pipefail
        mkdir -p parts
        seqtk seq ~{fasta} | awk '/^>/{f="parts/seq_" ++i ".fasta"} {print > f}'
        find parts/ -type f -size 0 -delete
        ls -l parts
    >>>

    output {
        Array[File] fasta_parts = glob("parts/*.fasta")
    }
}

task Count_Ns {
    input {
        File fasta
    }

    command <<<
        grep -o -i "N" ~{fasta} | wc -l > countNS.txt || echo 0 > countNS.txt
    >>>

    output {
        Int n_count = read_int("countNS.txt")
    }
}

task SumInts {
    input {
        Array[Int] values
    }

    command <<<
        echo "~{sep='\n' values}" | awk '{s+=$1} END {print s}' > total.txt
    >>>

    output {
        Int total = read_int("total.txt")
    }
}

workflow CountNs_fast {
    input {
        File fa
    }

    call SplitFasta {
        input: fasta = fa
    }

    scatter (f in SplitFasta.fasta_parts) {
        call Count_Ns {
            input: fasta = f
        }
    }

    call SumInts {
        input: values = Count_Ns.n_count
    }

    output {
        Int total_Ns = SumInts.total
    }

    runtime {
        docker: "biocontainers/seqtk:v1.3-4-deb_cv1"
    }
}
