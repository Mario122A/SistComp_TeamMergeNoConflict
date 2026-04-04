import requests

url = "https://api.worldbank.org/v2/en/country/all/indicator/SI.POV.GINI?format=json&date=2011:2020&per_page=3000"

print("Solicitando datos al Banco Mundial...")
respuesta = requests.get(url)

if respuesta.status_code == 200:
    print("Conexión exitosa\n")
else:
    print(f"Error en la solicitud. Código de estado: {respuesta.status_code}")
    exit()

datos_completos = respuesta.json()
lista_de_paises = datos_completos[1]

datos_argentina = []
for pais in lista_de_paises:
    if pais['country']['value'] == 'Argentina' and pais['value'] is not None:
        datos_argentina.append({
            'año': pais['date'],
            'indice_gini': float(pais['value'])
        })

if datos_argentina:
    print("Índice GINI para Argentina (2011-2020):")
    for registro in datos_argentina:
        print(f"  Año {registro['año']}: {registro['indice_gini']}")

else:
    print("No se encontraron datos de GINI para Argentina en el rango de años especificado.")
