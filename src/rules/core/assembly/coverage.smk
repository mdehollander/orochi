rule bamfiles:
    input:
        forward="scratch/host_filtering/{sample}_R1.fastq" if config['host_removal'] \
             else "scratch/filter/{sample}_R1.fq",
        rev="scratch/host_filtering/{sample}_R2.fastq" if config['host_removal'] \
             else "scratch/filter/{sample}_R2.fq",
        assembly = "scratch/assembly/megahit/minimus2/all.merged.contigs.fasta"
    output:
        temp("scratch/coverm/bamfiles/all.merged.contigs.fasta.{sample}_R1.fastq.bam")
    params:
        outdir=lambda wildcards, output: os.path.dirname(str(output))
    log:
        "logs/bamfiles/{sample}.bamfiles.log"
    conda:
        "../../../envs/coverm.yaml"
    threads: 40
    shell:
        "coverm make -p bwa-mem -r {input.assembly} -1 {input.forward} -2 {input.rev} -o {params.outdir} -t {threads} 2> {log}"
        
rule index_bam:
    input:
        "scratch/coverm/bamfiles/all.merged.contigs.fasta.{sample}_R1.fastq.bam"
    output:
        "scratch/coverm/bamfiles/all.merged.contigs.fasta.{sample}_R1.fastq.bam.bai"
    log:
        "logs/bamfiles/{sample}.index_bam.log"
    conda:
        "../../../envs/samtools.yaml"
    shell:
        "samtools index {input} {output} 2> {log}"

rule sort_readname:
    input:
        "scratch/coverm/bamfiles/all.merged.contigs.fasta.{sample}_R1.fastq.bam"
    output:
        "scratch/coverm/bamfiles/readsorted/{sample}.bam"
    log:
        "logs/bamfiles/{sample}.sort_readname.log"
    conda:
        "../../../envs/samtools.yaml"
    shell:
        "samtools sort -n {input} -o {output} 2> {log}"

rule coverage:
    input:
        expand("scratch/coverm/bamfiles/all.merged.contigs.fasta.{sample}_R1.fastq.bam", sample=config["data"])
    output:
        protected("results/stats/coverage/coverage.tsv")
    log:
        "logs/coverage.log"
    conda:
        "../../../envs/coverm.yaml"
    threads: 40
    shell:
        "coverm contig -b {input} -t {threads} > {output} 2> {log}"

"""
rule coverage_old:
    input:
        forward = expand("scratch/host_filtering/{sample}_R1.fastq", sample=config["data"]),
        rev = expand("scratch/host_filtering/{sample}_R2.fastq", sample=config["data"]),
#        assembly = "scratch/assembly/megahit/all/meta-large/final.contigs.fa"
        # TODO: Decide what is the input here
        assembly=expand("scratch/assembly/megahit/{treatment}/{kmers}/assembly.fa",treatment=config["treatment"], kmers=config["assembly-klist"])
    output:
        table=protected("results/stats/coverage.tsv")
    conda:
        "../../../envs/coverm.yaml"
    threads: 80
    # TODO: Add log file stderr
    shell:
        "coverm contig --mapper bwa-mem --methods mean --reference {input.assembly} -1 {input.forward} -2 {input.rev} --threads {threads} > {output.table}"
"""
