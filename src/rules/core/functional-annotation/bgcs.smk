"""
rule antismash:
    input:
        # TODO: Decide what is the input here
        expand("scratch/assembly/megahit/{treatment}/{kmers}/final.contigs.fa",treatment=config["treatment"], kmers=config["assembly-klist"])
    output:
        "scratch/annotation/antismash/secondary.contigs.gbk",
        "scratch/annotation/antismash/secondary.contigs.json"
    params:
        outdir="scratch/annotation/antismash/"
    conda:
        "../../../envs/antismash.yaml"
    threads: 16
    shell:
        "antismash --cb-general --cb-knownclusters --cb-subclusters --asf --genefinding-tool prodigal-m --output-dir {params.outdir} --cpus {threads} {input}"


rule get_bgcs:
    input:
        "scratch/annotation/antismash/secondary.contigs.json"
    output:
        "scratch/annotation/antismash/bgcs.fasta"
    script:
        "../../../scripts/antismash_get_bgcs.py"

rule map_reads:
    input:
        bgcs="scratch/annotation/antismash/bgcs.fasta",
        forward=expand("scratch/host_filtering/{sample}_R1.fastq", project=config["project"], sample=config["data"]),
        reverse=expand("scratch/host_filtering/{sample}_R2.fastq", project=config["project"], sample=config["data"])
    output:
        "scratch/annotation/antismash/bgcs.count.txt"
    conda:
        "../../../envs/coverm.yaml"
    log: "scratch/annotation/antismash/bgcs.mapping.txt"
    threads: 24
    shell:
        "coverm contig --methods count --mapper minimap2-sr --proper-pairs-only -1 {input.forward} -2 {input.reverse} --reference {input.bgcs} --threads {threads} 2> {log} > {output}"

if config['big']=='bigscape':
   rule bigscape:
        input:
            gbks="scratch/annotation/antismash/secondary.contigs.gbk"
        params:
            inputdir="scratch/annotation/antismash"
            outdir="scratch/annotation/{big}"
        output:
            web="scratch/annotation/bigscape/html_content"
    container:
        "docker://nselem/big-scape"
        conda:
            "../../../envs/bigscape.yaml"
        shell:
            "run_bigscape gbks -i {params.inputdir} -o {params.outdir}"

if config['big']=='bigslice':
   rule bigslice:
        input: "scratch/annotation/antismash/secondary.contigs.gbk"
        params:
            inputdir="scratch/annotation/antismash"
            outdir="scratch/annotation/{big}"
        output:
        conda:
            "../../../envs/bigslice.yaml"
        log:
        threads:
        shell:
            "download_bigslice_hmmdb"
            "bigslice -i <{params.inputdir}> <{params.outdir}>"

rule corason:
    input:
    output:
    container:
        "docker://nselem/corason"
    log:
    threads:
    shell:
"""
