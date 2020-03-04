__author__ = "Mattias de Hollander"
__copyright__ = "Copyright 2020, Mattias de Hollander"
__email__ = "m.dehollander@nioo.knaw.nl"
__license__ = "MIT"

from snakemake.utils import R, listfiles

if os.path.isfile("config.json"):
    configfile: "config.json"


# Dynamically load all modules/rules
smks = list(listfiles('src/rules/core/{section}/{part}.smk'))

for smk,rule in smks:
    include: smk

# Dynamically add all output files
output = []
for name,rule in rules.__dict__.items():
    for file in rule.output:
        output.append(file)

rule final:
    input: expand(output,\
                  sample=config["data"],\
                  treatment=config["treatment"],\
                  assembler=config["assembler"],\
                  kmers=config["assembly-klist"]\
                 )

