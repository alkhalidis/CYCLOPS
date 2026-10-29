library(tidyverse)
library(ComplexHeatmap)
library(scales)
library(circlize )
library(MASS)

#Option1: Import FlowJo exported populations 
Bcells=read_csv("FlowJoExport/Bcells_1.csv") %>% mutate(celltype="B cell") 
mDC1=read_csv("FlowJoExport/mDC1_1.csv")%>% mutate(celltype="mDC1")
mDC2=read_csv("FlowJoExport/mDC2_1.csv")%>% mutate(celltype="mDC2")
rDC1=read_csv("FlowJoExport/rDC1_1.csv")%>% mutate(celltype="rDC1")
rDC2=read_csv("FlowJoExport/rDC2_1.csv")%>% mutate(celltype="rDC2")
LEC=read_csv("FlowJoExport/LEC_1.csv")%>% mutate(celltype="LEC")
BEC=read_csv("FlowJoExport/BEC_1.csv")%>% mutate(celltype="BEC")
neutrophils=read_csv("FlowJoExport/neutrophils_1.csv")%>% mutate(celltype="neutrophils")
moncytes=read_csv("FlowJoExport/monocytes_1.csv")%>% mutate(celltype="monocytes")
FDC=read_csv("FlowJoExport/FDC_1.csv")%>% mutate(celltype="FDC")
FBC=read_csv("FlowJoExport/FBC_1.csv")%>% mutate(celltype="FBC")
negative=read_csv("FlowJoExport/negative1_1.csv")%>% mutate(celltype="negative")
CD4= read_csv("FlowJoExport/CD4_1.csv")%>% mutate(celltype="CD4")
CD8= read_csv("FlowJoExport/CD8_1.csv")%>% mutate(celltype="CD8")
Treg= read_csv("FlowJoExport/Treg_1.csv")%>% mutate(celltype="Treg")


#Make a master file of all gated populations
assigned_cell_type=rbind(CD3,Bcells, mDC1, mDC2, rDC1,rDC2, LEC,BEC,moncytes,negative1,negative2,  
                         negative3,XCR1dn, FDC, FBC,neutrophils)%>% 
  dplyr::mutate(ID3=stringr::str_pad(Cell_ID2, 4, side = "left", pad = 0),
                Cell_ID1=as.character(Cell_ID1),
                Cell_ID=paste0(Cell_ID1, ID3)) 

cell_type=data_norm%>% 
  left_join(assigned_cell_type )


#Option 2: Import R gated populations

assigned_cell_type=read_csv("All_Samples_Gated_Data.csv")

cell_type=assigned_cell_type%>% 
  dplyr::mutate(ID3=stringr::str_pad(Cell_ID2, 4, side = "left", pad = 0),
                Cell_ID1=as.character(Cell_ID1),
                Cell_ID=paste0(Cell_ID1, ID3))%>% 
  dplyr::select(-Cell_ID1, -Cell_ID2, -ID3)



#Start the LDA
cell_markers=c("CD3_", "CD4_","CD8_", "FOXP3", "Ly6C","Ly6G", "CD11b","CD11c", "B220", "Lyve1_2", "CD31_2", "CD35_2", "CD103", "MHCII", "XCR1")

all_data=cell_type%>%
  dplyr::select(Cell_ID,celltype, contains(cell_markers) ) %>% 
  mutate(Cell_ID=as.factor(Cell_ID))


matrix=all_data %>%
  column_to_rownames("Cell_ID") 

training <- matrix %>% dplyr::filter(!is.na(celltype)) 
testing <- matrix %>% dplyr::filter(is.na(celltype))

linear <- lda(celltype~., training)

p <- predict(linear, training)

lda_plot <- cbind(training, predict(linear)$x) %>% 
  rownames_to_column("Cell_ID")%>% 
  mutate(classtype="gated")


p1 <- predict(linear, training)$class
p1.df=as.data.frame(p1)
tab <-( table(Predicted = p1, Actual = training$celltype))
sum(diag(tab))/sum(tab)
tab.df=as.data.frame(tab)

p2 <- predict(linear, testing)

lda_plot2 <- cbind(testing, p2$x) %>% 
  mutate(celltype=p2$class) %>% 
  rownames_to_column("Cell_ID") %>% 
  mutate(classtype="predicted")


fitted_data=rbind(lda_plot, lda_plot2) %>%
  dplyr::select(Cell_ID, celltype)

all_fitted_celltypes =all_data %>% 
  dplyr::select(-celltype)%>% 
  left_join(fitted_data)



write_csv(all_fitted_celltypes, "all_fitted_celltypes.csv")


#Plot a heatmap to check the LDA prefeormance
cell_markers=c("CD3_", "CD4","CD8", "Ly6C", "CD11b","CD11c", "Ly6G", "B220", "Lyve1_2", "CD31_2", "CD35_2", "CD103", "MHCII", "FOXP3", "XCR1")

mat1=all_fitted_celltypes %>% 
  dplyr::select(celltype, contains(cell_markers)) %>%
  group_by(celltype) %>% 
  summarise(across(everything(), ~ mean(., na.rm = TRUE)))%>% 
  ungroup() %>% 
  dplyr::rename_all(funs(str_replace_all(.,c("_(.*)"="")))) %>% 
  column_to_rownames("celltype") %>% 
  scale() %>% 
  as.matrix()

ComplexHeatmap::Heatmap(mat1,  name = "Z-score", row_title = "Cell Type", column_title = "Antigen" )

