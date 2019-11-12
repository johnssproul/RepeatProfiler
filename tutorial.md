|| [Installation](readme.md) || [Getting Started](gettingstarted.md) || [Output](output.md) || [Application](uses.md) || 

# Tutorial

The individual profiles associated with specific read-to-reference mappings are in the subfolder named after the reference and index associated with that mapping.

### Basic Profiles

##### Horizontal Scaled Profile
This is the same profile shown in the scaled_profiles pdf located in the references folder. The scale is calculated based on the minimum and maximum across all reads for the reference with the lowest depth being blue and the highest depth, red. The purpose of this file is to provide cleaner information if you are interested in a specific read-to-reference mapping.

![](./pics/scaled_profile.png)

##### Simple Vector Profile
The simple vector profile is a single colored version of the horizontal gradient profile. This profile will be easier to edit for use in papers and posters and such.

![](./pics/simple_vector_profile.png)

##### Depth Counts
This file contains the "per position" information used in plotting the graphs. It contains the depth of every position and mismatches of A, T, C, and G.

![](./pics/depth.png)

##### Vertical Scaled Profile (Optional)
This profile is the same as the horizontal scaled and simple vector profile, but with a different style of color gradient. This color gradient goes from bottom to top rather than vertically. 

![](./pics/vertical.png)

Because this profile takes much more time to produce algorihtmically and it is the same as two of the other outputs, we decided to leave its production to your discretion. To generate the vertical scaled profile, use the command:

```
put command here
```


### Correlation Plots

##### Boxplot - by Groups
The correlation boxplot by groups shows boxplots of correlation values for each group (and its outgroups) specified in the user_groups.txt.

![](./pics/groupcorr.png)

##### Boxplot - by References
The correlation boxplot by references shows boxplots of correlation values for a given reference by ingroup and outgroup.

![](./pics/refcorr.png)

##### Histogram
The correlation histogram plots the correlation for each pair of within and between pairing.

![](./pics/histogram.png)


### Phylogenetic Analysis

##### Variation Plot
This is the same plot shown in the variant_profiles pdf located in the references folder. The main purpose of this file is to provide cleaner information if you are interested in a specific read-to-reference mapping.

![](./pics/variant_profile.png)

##### Phylip
There is much more information in the variation profiles than meets the eye. These plots were produced from the phylip file (found in the reference folder). This file is named as reference_name.phy.

![](./pics/phylip.png)

We were able to capture phylogenetic informative sites from the variation plots explained above. We analyzed each plot indivudaly and recored the bases that had mismatch coverage over 10% from the actual coverage. We also accounted for ambigous sites.

The phylip files are most informative for long refrence sequences (1000+ bases) and can be used in your favorite tree software. We used [iq-tree](http://www.iqtree.org/).


The best way to use this file is to run many tests and choose proper refrence sequences corrosponding to what you want to test. See [applications](uses.md) for more information on how to use RepeatProfiler in conjunction with phylogenetic analysis.
