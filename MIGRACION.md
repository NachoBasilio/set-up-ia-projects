# Migración: AGENTS + Skills

Plan para mantener este repo a la vanguardia sin convertirlo en un museo.

## Objetivo

Migrar y mantener `AGENTS.md` y `Skills/*/SKILL.md` alineados con:
- Formato moderno de skills
- Taxonomía `capability_uplift` vs `encoded_preference` 
- Principio anti-ruido (menos contexto inútil = mejores resultados)

## Versiones target

- **AGENTS v2.x**: breve, verificable, sin duplicación
- **Skills v2.x**: `Skills/<name>/SKILL.md` + metadata obligatoria

## Principios

1. **Minimalismo operativo**: menos texto, más reglas accionables
2. **Compatibilidad sin deuda**: legacy solo como puente temporal  
3. **Evidencia antes de reglas**: no inventar políticas sin base
4. **Evolución controlada**: versionar cambios, definir retiro

## Taxonomía de skills

Definición completa (`capability_uplift` vs `encoded_preference`) y reglas de ciclo de vida: ver `START-UP.md` (FASE 4).

## Plan ejecutable

### 1. Inventario (15 min)
```bash
# Listar skills y detectar gaps
find Skills/ -name "*.md" | sort
./scripts/validate-skills.sh --dry-run
```

**Output**: tabla con skill, ruta, tipo, estado (moderna/legacy), riesgo

### 2. Normalización de estructura (30 min)
```bash
# Convertir a Skills/<name>/SKILL.md
# Mantener Skills/*.md como redirect temporal
```

**Target**: cero skills activas en formato legacy

### 3. Metadata obligatoria (20 min)

Completar en todas las skills:
- `name`, `description`, `license`
- `metadata.author`, `version`, `scope`, `auto_invoke`  
- `metadata.owner`, `skill_type`, `risk_level`, `allowed_tools`
- `metadata.review_by` (obligatorio para `capability_uplift`)

**Comando**: `./scripts/validate-skills.sh`

### 4. Alineación documental (10 min)

- Actualizar `AGENTS.md` con fuente de verdad  
- Mantener `README.md` actualizado
- `START-UP.md` como protocolo de configuración

**Target**: sin contradicciones entre docs

### 5. Retiro de legacy (cuando se necesite)

- Fecha de corte para redirects `Skills/*.md`
- Breaking change en release notes
- Eliminar redirects después de ventana de compatibilidad

**Target**: solo formato moderno

## Mantenimiento (vanguardia real)

**Cadencia**:
- **Mensual**: review de `capability_uplift`
- **Ad-hoc**: release fuerte de modelo
  
**Clasificación por revisión**:
- `keep`: sigue aportando valor
- `refine`: requiere ajuste  
- `sunset`: retirar por obsolescencia

## Comandos útiles

**Validación**: `scripts/validate-skills.sh` es el validador de metadata de skills (estructura y frontmatter), distinto de la etapa VALIDATE por tarea del flujo programático. Ver [QUICKSTART.md](QUICKSTART.md) sección "4. Validar setup".

**Inventario rápido**:
```bash
find Skills/ -name "SKILL.md" -exec grep -l "capability_uplift" {} \;
find Skills/ -name "SKILL.md" -exec grep -l "review_by" {} \;
```

## Checklist de migración

- [ ] No skills nuevas en `Skills/*.md`
- [ ] Toda skill declara `skill_type`  
- [ ] `capability_uplift` tienen `review_by`
- [ ] `AGENTS.md` no duplica contenido
- [ ] `README.md` explica tipos de skills
- [ ] Rutas válidas (`Skills/` correcto)
- [ ] `./scripts/validate-skills.sh` exitoso

## Definition of done

✅ Estructura moderna aplicada  
✅ Taxonomía auditable  
✅ Legacy encapsulado o retirado  
✅ Documentación consistente y sin ruido
