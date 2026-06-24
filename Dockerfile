# ---- Etapa 1: builder ----
FROM python:3.12-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# ---- Etapa 2: runtime ----
FROM python:3.12-slim
WORKDIR /app

# Usuario no root por seguridad
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY app/ ./app/

USER appuser
EXPOSE 8005

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8005"]