library(CytoExploreR)
library(tidyverse)
library(flowWorkspace)
library(CytoML)

#Place all FlowJo files in a single directory, and define this directory below

setwd("C:/Users/salkhali/OneDrive - University of Glasgow/Paper2/revisions/FlowJoOS")
gs <- cyto_setup(path = "fcs", gatingTemplate =( "gatingTemplate.csv"), 
                 truncate_max_range = FALSE)

#Uncomment and run the following if continuing gating from a previously saved gatingTemplate
cyto_gatingTemplate_apply(gs, gatingTemplate = "gatingTemplate.csv") 

cyto_gate_draw(gs,
               parent = "root",
               alias = #"LEC",
               #"BEC",
               "Immune",
               channels = c("Parameter_26", "Parameter_27"), # Replace with your actual channel/marker names
               type = "rectangle",# Choose type: "polygon", "rectangle", "ellipse", etc.
               xlim = c(-0.5, 4), # Adjust based on your channel scale
               ylim = c(-0.5, 4),
               gatingTemplate = "gatingTemplate.csv")

cyto_gate_draw(gs,
               parent = "Immune",
               alias = #"FC",
               "nonFC",
               channels = c("Parameter_28", "Parameter_22"), # Replace with your actual channel/marker names
               type = "polygon",# Choose type: "polygon", "rectangle", "ellipse", etc.
               xlim = c(-0.5, 4), # Adjust based on your channel scale
               ylim = c(-1, 4),
               gatingTemplate = "gatingTemplate.csv")

cyto_gate_draw(gs,
               parent = "FC",
               alias = "FBC",
                 #"FDC",
               channels = c("Parameter_21", "Parameter_28"), # Replace with your actual channel/marker names
               type = "rectangle",# Choose type: "polygon", "rectangle", "ellipse", etc.
               xlim = c(-1, 2.5), # Adjust based on your channel scale
               ylim = c(-1, 4),
               gatingTemplate = "gatingTemplate.csv")

cyto_gate_draw(gs,
               parent = "nonFC",
               alias = #"Bcells",
                        "Tcells",
                        #"dn",
               channels = c("Parameter_11", "Parameter_21"), # Replace with your actual channel/marker names
               type = "polygon",# Choose type: "polygon", "rectangle", "ellipse", etc.
               xlim = c(-2, 4), # Adjust based on your channel scale
               ylim = c(-1, 2),
               gatingTemplate = "gatingTemplate.csv")

cyto_gate_draw(gs,
               parent = "Tcells",
               alias = #"Treg",
                 "nonTreg",
               channels = c("Parameter_12", "Parameter_22"), # Replace with your actual channel/marker names
               type = "polygon",# Choose type: "polygon", "rectangle", "ellipse", etc.
               xlim = c(-1, 3), # Adjust based on your channel scale
               ylim = c(-1, 4),
               gatingTemplate = "gatingTemplate.csv")

cyto_gate_draw(gs,
               parent = "nonTreg",
               alias = "CD8",
               #"CD4",
               channels = c("Parameter_12", "Parameter_13"), # Replace with your actual channel/marker names
               type = "polygon",# Choose type: "polygon", "rectangle", "ellipse", etc.
               xlim = c(-1, 3), # Adjust based on your channel scale
               ylim = c(-1, 3),
               gatingTemplate = "gatingTemplate.csv")

cyto_gate_draw(gs,
               parent = "dn",
               alias =#"Neutrophils",
               "Ly6Gneg",
               channels = c("Parameter_8", "Parameter_19"), # Replace with your actual channel/marker names
               type = "rectangle",# Choose type: "polygon", "rectangle", "ellipse", etc.
               xlim = c(-1, 4), # Adjust based on your channel scale
               ylim = c(-1, 5),
               gatingTemplate = "gatingTemplate.csv")

cyto_gate_draw(gs,
               parent = "Ly6Gneg",
               alias = "Ly6Cneg",
                 #"Monocytes",
               channels = c("Parameter_17", "Parameter_5"), # Replace with your actual channel/marker names
               type = "rectangle",# Choose type: "polygon", "rectangle", "ellipse", etc.
               xlim = c(-1, 3.5), # Adjust based on your channel scale
               ylim = c(-1, 4),
               gatingTemplate = "gatingTemplate.csv")

cyto_gate_draw(gs,
               parent = "Ly6Cneg",
               alias = #"DCs",
                 "negative",
               channels = c("Parameter_16", "Parameter_20"), # Replace with your actual channel/marker names
               type = "rectangle",# Choose type: "polygon", "rectangle", "ellipse", etc.
               xlim = c(-1, 4), # Adjust based on your channel scale
               ylim = c(-1.5, 3.5),
               gatingTemplate = "gatingTemplate.csv")

cyto_gate_draw(gs,
                parent = "DCs",
                alias = "DC1",
                #"DC2",
                channels = c("Parameter_5", "Parameter_7"), # Replace with your actual channel/marker names
                type = "rectangle",# Choose type: "polygon", "rectangle", "ellipse", etc.
                xlim = c(-1, 3), # Adjust based on your channel scale
                ylim = c(-1.5, 3),
                gatingTemplate = "gatingTemplate.csv")

cyto_gate_draw(gs,
               parent = "DC1",
               alias = #"rDC1",
                 "mDC1",
               channels = c("Parameter_6", "Parameter_13"), # Replace with your actual channel/marker names
               type = "polygon",# Choose type: "polygon", "rectangle", "ellipse", etc.
               xlim = c(-1, 3.5), # Adjust based on your channel scale
               ylim = c(-1, 3),
               gatingTemplate = "gatingTemplate.csv")

cyto_gate_draw(gs,
               parent = "DC2",
               alias = "rDC2",
               #"mDC2",
               channels = c("Parameter_20", "Parameter_4"), # Replace with your actual channel/marker names
               type = "rectangle",# Choose type: "polygon", "rectangle", "ellipse", etc.
               xlim = c(-1, 3), # Adjust based on your channel scale
               ylim = c(-3, 3),
               gatingTemplate = "gatingTemplate.csv")


 cyto_plot_gating_scheme(gs[5], label_stat = NA,           # Removes percentages
                         #point_col_alpha = 0.6,     # Softens overlap transparency for a blended look
                         #point_size = 0.8,          # Optimized dot size for smooth visual transitions
                         gate_line_col = "black")
 
 #Apply the gating saved in the gatingTemplate to all your samples. 
 cyto_gatingTemplate_apply(gs, gatingTemplate = "gatingTemplate.csv") #Also run at the start of the code if the gating is paused to be finished at a later date
 
 #You can now export the gating scheme to visualise how it is doing per sample
 for (i in seq_along(gs)) {
   
   # Extract the name of the current sample for the filename
   sample_name <- sampleNames(gs)[i]
   
   # Choose your format: ".svg" or ".pdf" for vector editing in Illustrator, or ".png"
   file_name <- paste0("Gating_Scheme_", sample_name, ".svg")
   
   # 1. Initialize the save device (adjust width and height as needed)
   cyto_plot_save(file_name, width = 12, height = 10)
   
   # 2. Draw the plot (using your preferred settings, e.g., without statistics)
   cyto_plot_gating_scheme(gs[i], label_stat = NA,           # Removes percentages
                           #point_col_alpha = 0.6,     # Softens overlap transparency for a blended look
                           #point_size = 0.8,          # Optimized dot size for smooth visual transitions
                           gate_line_col = "black")
   
   # 3. Finalize and close the saved file device
   cyto_plot_complete()
 }
 
 
 library(flowWorkspace)
 library(flowCore)
 
 data_list <- list()
 
 # Loop through each sample in your GatingSet
 for (i in seq_along(gs)) {
   
   sample_name <- sampleNames(gs)[i]
   message("Processing: ", sample_name)
   
   # 1. Extract the flowFrame and convert to a data frame
   ff <- getData(gs[[i]])
   cell_data <- as.data.frame(exprs(ff))
   
   # 2. Extract channel names and marker descriptions from the flowFrame metadata
   pd <- Biobase::pData(flowCore::parameters(ff))
   channels <- pd$name    # e.g., "Parameter_8"
   markers <- pd$desc     # e.g., "B220"
   
   # 3. Combine them (e.g., "Parameter_8_B220"), or fall back to the channel name if no marker exists (like FSC-A)
   new_colnames <- ifelse(!is.na(markers) & markers != "", 
                          paste0(markers), 
                          channels)
   
   # Apply the updated column names to your cell data frame
   colnames(cell_data) <- new_colnames
   
   # 4. Add tracking columns
   cell_data$sample_ID <- sample_name
   cell_data$celltype <- NA
   
   # 5. Assign clean gate names
   leaf_nodes <- gs_get_leaf_nodes(gs[[i]])
   for (node in leaf_nodes) {
     short_name <- basename(node)
     indices <- gh_pop_get_indices(gs[[i]], node)
     cell_data$celltype[indices] <- short_name
   }
   
   data_list[[i]] <- cell_data
 }
 
 # 6. Combine all samples into one master file and export
 master_data <- do.call(rbind, data_list)
 write.csv(master_data, file = "All_Samples_Gated_Data.csv", row.names = FALSE)
 
