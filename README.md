# apuestas-service

Microservicio de **apuestas deportivas** del casino (FastAPI). Comparte la base de
datos PostgreSQL y el `JWT_SECRET` con `casino-backend` (no tiene login propio:
valida el JWT que emite el backend). Lista eventos con cuotas 1X2, registra
apuestas, **simula** el partido (modelo Poisson) y liquida las apuestas; los
equipos/escudos se siembran desde thesportsdb.

- Prefijo de rutas: `/api/apuestas` · Docs: `/docs`

## Endpoints
| Método | Ruta | Descripción |
|---|---|---|
| GET | `/api/apuestas/eventos` | Eventos abiertos con cuotas y escudos |
| POST | `/api/apuestas` | Registrar una apuesta (debita saldo) |
| GET | `/api/apuestas/mis-apuestas` | Apuestas del usuario |
| POST | `/api/apuestas/eventos/{id}/simular` | Simula y liquida el partido |
| POST | `/api/apuestas/reiniciar` | Regenera la cartelera |

## Ejecutar en local
```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
# variables: copia .env.example a .env y ajústalas
uvicorn app.main:app --reload --port 8005
```
Requiere una PostgreSQL accesible con las tablas compartidas (`usuarios`,
`transacciones`) que crea `casino-backend`.

## Entrega (lo que debes implementar)
1. **Rutas de salud** para Kubernetes (ver el `TODO` en `app/main.py`):
   *liveness* (¿el proceso vive?) y *readiness* (¿listo para tráfico? verifica la BD, responde 200/503).
2. **Dockerfile** para contenerizar el servicio.
3. **Workflow de CI/CD** (GitHub Actions) que construya la imagen, la publique en ECR y despliegue en **EKS**.
4. **Manifiestos de Kubernetes** (Deployment + Service) con las probes apuntando a tus rutas de salud.
5. **Pruebas de carga** que evidencien el correcto funcionamiento en EKS (escalado, disponibilidad).

## Variables de entorno requeridas

| Variable | Descripción |
|----------|-------------|
| DB_HOST | Host de PostgreSQL |
| DB_PORT | Puerto de PostgreSQL (default 5432) |
| DB_NAME | Nombre de la base de datos |
| DB_USER | Usuario de la base de datos |
| DB_PASSWORD | Contraseña (viene del Secret k8s) |
| JWT_SECRET | Clave para validar tokens JWT |

## Sondas de salud implementadas

| Ruta | Tipo | Respuesta |
|------|------|-----------|
| /livez | Liveness | 200 siempre |
| /readyz | Readiness | 200 BD ok / 503 sin BD |

Puerto: 8005

## Despliegue en EKS

```bash
kubectl apply -f k8s/
kubectl get pods
kubectl logs deploy/apuestas-service
kubectl get hpa
```

## Troubleshooting

- **CrashLoopBackOff:** revisar variables del Secret casino-secrets
- **Readiness falla (503):** PostgreSQL no alcanzable, verificar casino-secrets
- **Pipeline falla:** credenciales AWS Academy expiradas, actualizar GitHub Secrets