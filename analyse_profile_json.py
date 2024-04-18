
import json
import numpy as np

class ProfileJsonAnalyser(object):
    """ Class to extract metrics from the profile.json produced by Scalene"""

    def __init__(self) : 
        # get-dem ellapsed time
        self.elapsed_time_list = []
        # Maximum RAM
        self.max_footprint_mb_last = []

        # Metrics for line of code where n_cpu_percent_c!=0
        self.relevant_loc_metrics = {}

    
    def parse_jsons(self, profile_json_path_list):
        """ Parse and collect metrics of the given profile.json list

        profile_json_path_list : Path of all profile.json to parse 
        """

        for profile_json_path in profile_json_path_list :
            with open(profile_json_path) as f:
                profile_json= json.load(f)
        
            # gather fisrt level metrics
            self.elapsed_time.append(float(profile_json['elapsed_time_sec']))
            self.max_footprint_mb.append(float(profile_json['max_footprint_mb']))
        
            # Gather LOC metrics 
            for line_of_code_metric in profile_json["files"]["/opt/get-dem/get_dem.py"]["lines"]:
                # Keep only LOC with CPU load
                if line_of_code_metric["n_cpu_percent_c"] != 0.0 :
                
                    if line_of_code_metric['lineno'] not in self.relevant_loc_metrics:
                        self.relevant_loc_metrics[line_of_code_metric['lineno']] = {"line":line_of_code_metric['line'],'n_core_utilization':[],'n_peak_mb':[]}
                        
                    self.relevant_loc_metrics[line_of_code_metric['lineno']]['n_core_utilization'].append(float(line_of_code_metric['n_core_utilization']))
                    self.relevant_loc_metrics[line_of_code_metric['lineno']]['n_peak_mb'].append(float(line_of_code_metric['n_peak_mb']))

    
    def print_average(self):
        """ Print the averge of collected metrics"""

        print( "Average elapsed time : {:.2f} sec".format(np.mean(self.elapsed_time)))
        print( "Average maximum RAM footprint  : {:.2f} Mb".format(np.mean(self.max_footprint_mb)))


        print("\n===== Relevant Line-Of-Code metrics =====\n")
        for met_loc in self.relevant_loc_metrics:
            print( "line {} : {}".format(met_loc,self.relevant_loc_metrics[met_loc]["line"]))
            print( "\tAverage n_core_utilization : {:.2f} sec".format(np.mean(self.relevant_loc_metrics[met_loc]["n_core_utilization"])))
            print( "\tAverage n_peak_mb : {:.2f} Mo".format(np.mean(self.relevant_loc_metrics[met_loc]["n_peak_mb"])))
            print(" \n ----- \n")