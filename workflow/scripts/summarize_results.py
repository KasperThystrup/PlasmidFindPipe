import pandas
import logging

sys.exit(0)
logging.basicConfig(filename='logs/summarise_results.log', level=logging.DEBUG)

def extract_sample_name(plasmid_file):
  sample_raw = plasmid_file.split(".")[-1]
  sample = sample_raw.join(".")

  return(sample)
  

def read_plasmid(plasmid_file, sample):
  plasmid = pandas.read_csv(plasmid_file, sep = "\t")
  plasmid["Sample"] = sample

  return(plasmid)


def summarise_results(plasmid_files, summary_file):
  plasmid_raw = list()
  
  print("Itterating plasmid results")
  for plasmid_file in plasmid_files:
    sample = extract_sample_name(plasmid_file)
    
    plasmid = read_plasmid(plasmid_file, sample)
    plasmid_raw.append(plasmid)
    
  print(plasmid_raw, sep = "\n")

  summary = plasmid_raw.concat(ignore.index = True)

  summary.to_csv(summary_file, sep = "\t", index = False)


def main():
  plasmid_files = snakemake.input["plasmid_files"]
  summary_file = snakemake.output["summary_file"]

  try:
    summarise_results(plasmid_files, summary_file)
    logging.info('Script finished successfully')
  except Exception as e:
    logging.error('Error occurred: %s', e)
    raise

logging.info('Starting script')
print("Starting script")
if __name__ == '__main__':
    main()