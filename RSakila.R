install.packages("dplyr")      # Manipulation de données
install.packages("ggplot2")    # Graphiques
install.packages("readr")      # Lecture de fichiers CSV
install.packages("factoextra") # Visualisation de clustering (optionnel)

library(dplyr)        
library(ggplot2)      
library(readr)        
library(factoextra)   

#IMPORTER LES FICHIERS
customer = read.csv("customer.CSV", header = FALSE)
colnames(customer) <- c("customer_id", "store_id", "first_name", "last_name", "email", "address_id", "active", "create_date", "last_update")
customer

payment = read.csv("payments.CSV", header = FALSE)
payment
colnames(payment) = c("payment_id", "customer_id", "staff_id", "rental_id", "amount", "payment_date", "last_update")

rental = read.csv("rental.CSV", header = FALSE)
colnames(rental) <- c("rental_id", "rental_date", "inventory_id", "customer_id", "return_date", "staff_id", "last_update")
rental

#CHIFFRE D'AFFAIRES PAR CLIENT
ca_par_client = payment %>%
  group_by(customer_id) %>%
  summarize(
    total_spent = sum(amount),
    nb_payment = n(),
    .groups = "drop"
  )

ca_par_client

#JOINTURE 
base_client = ca_par_client %>%
inner_join(customer, by = "customer_id")

head(base_client)

base_client = base_client %>%
  mutate(full_name = paste(first_name, last_name))

top_clients = base_client %>%
  arrange(desc(total_spent)) %>%
  slice_head(n = 10)

ggplot(top_clients, aes(x = reorder(full_name, total_spent), y = total_spent)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(
    title = "Top 10 Customers by Total Spending",
    x = "Customer",
    y = "Total Spent ($)"
  ) +
  theme_minimal()

#CLUSTERING

client_clust_data <- base_client %>%
  select(customer_id, total_spent, nb_payment) %>%
  na.omit()

#Elbow Method
data_clust <- base_client %>%
  select(total_spent, nb_payment) %>%
  na.omit()

fviz_nbclust(data_clust, kmeans, method = "wss") +
  labs(
    title = "Elbow Method - Optimal Number of Clusters",
    x = "Number of Clusters (k)",
    y = "Within Sum of Squares (WSS)"
  )

#Silhouette Method
fviz_nbclust(data_clust, kmeans, method = "silhouette") +
  labs(
    title = "Silhouette Method - Optimal Number of Clusters",
    x = "Number of Clusters (k)",
    y = "Average Silhouette Width"
  )

#K-Means 

client_clust_data <- base_client %>%
  select(customer_id, total_spent, nb_payment) %>%
  na.omit()

set.seed(123)
kmeans_result <- kmeans(client_clust_data[, c("total_spent", "nb_payment")], centers = 3)

client_clust_data$cluster <- as.factor(kmeans_result$cluster)
ggplot(client_clust_data, aes(x = total_spent, y = nb_payment, color = cluster)) +
  geom_point(size = 3, alpha = 0.7) +
  labs(
    title = "Customer Clustering by Behavior",
    x = "Total Spent ($)",
    y = "Number of Payments",
    color = "Cluster"
  ) +
  theme_minimal()

#Analyse des 3 clusters

data_clust %>%
  group_by(cluster) %>%
  summarise(
    avg_spent = round(mean(total_spent), 2),
    avg_payment = round(mean(nb_payment), 2),
    count = n()
  )
