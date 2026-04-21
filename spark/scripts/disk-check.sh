#!/usr/bin/env bash
echo "== disk usage =="
df -h

echo ""
echo "== /opt/ai usage =="
du -sh /opt/ai/* 2>/dev/null || echo "/opt/ai not found"

echo ""
echo "== docker volumes =="
docker system df 2>/dev/null || echo "docker not available"
