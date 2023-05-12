import csv
import os
import shutil
import sys

csv.field_size_limit(sys.maxsize)

# Lecture du fichier d'entrée
with open('validationErrors.csv', 'r') as csv_file:
    reader = csv.DictReader(csv_file)
    data = [row for row in reader]

# Regroupement des objectIds par error
grouped_data = {}
for row in data:
    error_type = row['errorsTypes'].split(',')[-1]
    object_id = row['objectId']
    if error_type not in grouped_data:
        grouped_data[error_type] = []
    grouped_data[error_type].append(object_id)

# Calcul du taux pour chaque erreur en pourcentage
total_objects = len(data)
output_data = []
for error_type, object_ids in grouped_data.items():
    count = len(object_ids)
    taux = count / total_objects * 100  # Calcul du taux en pourcentage
    output_data.append({
        'error': error_type,
        'taux': f"{taux:.2f}%",  # Formattage du taux en tant que pourcentage
        'objectIds': ', '.join(object_ids)
    })

# Écriture du fichier de sortie
with open('errorClassification.csv', 'w', newline='') as csv_file:
    fieldnames = ['error', 'taux', 'objectIds']
    writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
    writer.writeheader()
    for row in output_data:
        writer.writerow(row)
