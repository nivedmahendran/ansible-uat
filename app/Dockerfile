FROM python:3.12-slim

# Create the runtime user before switching to it. A fixed uid keeps the image
# consistent with the pod securityContext, which pins runAsUser: 10001 — if the
# two disagreed, the container would fail to start with a permission error.
RUN useradd --uid 10001 --create-home --shell /usr/sbin/nologin appuser

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .

# The Kubernetes manifest also sets runAsNonRoot and a read-only root
# filesystem. Declaring it here as well means the image is safe to run
# anywhere, not only under those manifest settings.
USER 10001

EXPOSE 5000
CMD ["python", "app.py"]
