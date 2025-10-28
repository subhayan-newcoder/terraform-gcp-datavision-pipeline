# 🌩️ Terraform GCP DataVision Pipeline

## 📘 Project Overview

**Terraform GCP DataVision Pipeline** is an Infrastructure-as-Code (IaC) project that automates the deployment of a **serverless data ingestion pipeline** in **Google Cloud Platform (GCP)** using **Terraform**.

This project demonstrates how to build a **secure, modular, and multi-environment** (dev & prod) cloud architecture that processes data files automatically from **Cloud Storage** into **BigQuery** via **Pub/Sub** and **Cloud Functions**.

---

## 🧠 Key Concepts Practiced

* **Terraform Core Concepts:** Providers, resources, variables, outputs, dependencies
* **Modular Design:** Independent, reusable Terraform modules for each GCP component
* **Environment Management:** Separate configurations and state for `dev` and `prod`
* **IAM & Security:** Custom service accounts and least-privilege IAM role assignments
* **Remote State Management:** Backend in GCS with state locking and isolation
* **Serverless Data Processing:** Integration of GCS → Pub/Sub → Cloud Function → BigQuery

---

## 🏗️ Architecture Overview

### Workflow:

![Workflow Diagram](./arch-diagram.jpg?raw=true)

1. A json file is uploaded to a **GCS input bucket**.
2. The upload event triggers a **Pub/Sub topic**.
3. A **Cloud Function**, subscribed to the topic, processes the file:

   * Reads the file from GCS.
   * Loads data into a **BigQuery table**.
   * Moves the processed file to an **archive bucket**.
4. Logging and error tracking are handled through **Cloud Logging & Monitoring**.

### Core GCP Components:

* **Google Cloud Storage (GCS)** – Input and archive buckets
* **Pub/Sub** – Event notification and message handling
* **Cloud Functions** – Serverless processing logic
* **BigQuery** – Target data warehouse
* **Cloud IAM** – Access control and least-privilege roles
* **Cloud Monitoring (Optional)** – Basic dashboards and alerts

---

## 🧩 Project Structure

```
terraform-gcp-datavision/
│
├── main.tf
├── variables.tf
├── outputs.tf
├── backend.tf
│
├── envs/
│   ├── dev.tfvars
│   └── prod.tfvars
│
├── modules/
│   ├── storage/
│   ├── pubsub/
│   ├── cloud_function/
│   ├── bigquery/
│   └── monitoring/        # optional
│
└── README.md
```

---

## 🚀 Deployment Instructions

### Prerequisites:

* Terraform installed (v1.5+ recommended)
* GCP project with required APIs enabled:

  * `cloudfunctions.googleapis.com`
  * `pubsub.googleapis.com`
  * `bigquery.googleapis.com`
  * `storage.googleapis.com`

### Steps:

1. Clone the repository:

   ```bash
   git clone https://github.com/<your-username>/terraform-gcp-datavision-pipeline.git
   cd terraform-gcp-datavision-pipeline
   ```
2. Initialize Terraform:

   ```bash
   terraform init
   ```
3. Deploy for the desired environment:

   ```bash
   terraform apply -var-file=envs/dev.tfvars
   ```
4. Upload a CSV file to the GCS input bucket and verify:

   * Pub/Sub message triggers
   * Cloud Function processes data
   * BigQuery table populated
   * File archived successfully

---

## 📊 Learning Outcomes

By completing this project, you will:

* Understand **how to modularize Terraform configurations** for scalability.
* Learn **how to manage multiple environments** using `.tfvars` and workspaces.
* Gain experience with **IAM design**, **GCP service integration**, and **state management**.
* Build a **production-ready data pipeline** entirely through Infrastructure as Code.

---

## 🌟 Future Enhancements

* Add **Cloud Scheduler** to trigger daily validation tasks.
* Add **lifecycle rules** to manage archive bucket retention.
* Add **monitoring dashboards** via Terraform.
* Extend Cloud Function to perform schema validation or data transformation.

---

## 🧾 License

This project is for learning and demonstration purposes. You can adapt and reuse the Terraform structure for your own GCP projects.
