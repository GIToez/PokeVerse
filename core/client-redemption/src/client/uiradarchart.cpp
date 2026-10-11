/*
 * Copyright (c) 2010-2026 OTClient <https://github.com/edubart/otclient>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#include "uiradarchart.h"

#include <cmath>
#include <numbers>

#include <framework/graphics/drawpoolmanager.h>
#include <framework/otml/otmlnode.h>

void UIRadarChart::setAxisCount(const int count)
{
    m_axisCount = std::max<int>(3, count);
}

size_t UIRadarChart::addLayer(const Color& fillColor, const Color& lineColor, const int lineWidth)
{
    m_layers.push_back(Layer{ std::vector<float>(m_axisCount, 0.f), fillColor, lineColor, std::max<int>(1, lineWidth), true });
    return m_layers.size() - 1;
}

void UIRadarChart::setLayerValues(const size_t index, const std::vector<float>& values)
{
    if (index >= m_layers.size())
        return;

    auto& layer = m_layers[index];
    layer.values.assign(m_axisCount, 0.f);
    for (size_t i = 0; i < values.size() && i < layer.values.size(); ++i)
        layer.values[i] = std::clamp<float>(values[i], 0.f, 1.f);
}

void UIRadarChart::setLayerVisible(const size_t index, const bool visible)
{
    if (index < m_layers.size())
        m_layers[index].visible = visible;
}

PointF UIRadarChart::getVertex(const PointF& center, const float radius, const int axis, const float value) const
{
    const double angle = -std::numbers::pi / 2 + 2 * std::numbers::pi * axis / m_axisCount;
    return { center.x + static_cast<float>(std::cos(angle) * radius * value),
             center.y + static_cast<float>(std::sin(angle) * radius * value) };
}

Point UIRadarChart::getAxisPoint(const int axis, const float value)
{
    const Rect rect = getPaddingRect();
    const PointF center(rect.width() / 2.f, rect.height() / 2.f);
    const float radius = std::min<int>(rect.width(), rect.height()) / 2.f;
    const PointF vertex = getVertex(center, radius, axis, value);
    return { static_cast<int>(std::lround(vertex.x)) + rect.x() - m_rect.x(),
             static_cast<int>(std::lround(vertex.y)) + rect.y() - m_rect.y() };
}

// GL line widths above 1 are not supported everywhere, so lines are thin quads
void UIRadarChart::drawLine(const PointF& a, const PointF& b, const int width, const Color& color) const
{
    const float dx = b.x - a.x;
    const float dy = b.y - a.y;
    const float length = std::sqrt(dx * dx + dy * dy);
    if (length < 0.5f)
        return;

    const float nx = -dy / length * width / 2.f;
    const float ny = dx / length * width / 2.f;
    const auto toPoint = [](const float x, const float y) { return Point(static_cast<int>(std::lround(x)), static_cast<int>(std::lround(y))); };
    const Point p1 = toPoint(a.x + nx, a.y + ny);
    const Point p2 = toPoint(b.x + nx, b.y + ny);
    const Point p3 = toPoint(b.x - nx, b.y - ny);
    const Point p4 = toPoint(a.x - nx, a.y - ny);
    g_drawPool.addFilledTriangle(p1, p2, p3, color);
    g_drawPool.addFilledTriangle(p1, p3, p4, color);
}

void UIRadarChart::drawSelf(const DrawPoolType drawPane)
{
    UIWidget::drawSelf(drawPane);
    if (drawPane != DrawPoolType::FOREGROUND)
        return;

    const Rect rect = getPaddingRect();
    if (!rect.isValid())
        return;

    const PointF center(rect.x() + rect.width() / 2.f, rect.y() + rect.height() / 2.f);
    const float radius = std::min<int>(rect.width(), rect.height()) / 2.f - 1;
    const Point centerPoint(static_cast<int>(std::lround(center.x)), static_cast<int>(std::lround(center.y)));

    for (int ring = 1; ring <= m_ringCount; ++ring) {
        const float value = static_cast<float>(ring) / m_ringCount;
        for (int axis = 0; axis < m_axisCount; ++axis)
            drawLine(getVertex(center, radius, axis, value), getVertex(center, radius, (axis + 1) % m_axisCount, value), m_gridWidth, m_gridColor);
    }
    for (int axis = 0; axis < m_axisCount; ++axis)
        drawLine(center, getVertex(center, radius, axis, 1.f), m_gridWidth, m_gridColor);

    for (const auto& layer : m_layers) {
        if (!layer.visible)
            continue;

        std::vector<PointF> vertices;
        vertices.reserve(m_axisCount);
        for (int axis = 0; axis < m_axisCount; ++axis)
            vertices.push_back(getVertex(center, radius, axis, layer.values[axis]));

        // every layer is star-shaped around the centre, so a fan from the centre fills it
        if (layer.fillColor.aF() > Fw::MIN_ALPHA) {
            for (int axis = 0; axis < m_axisCount; ++axis) {
                const PointF& a = vertices[axis];
                const PointF& b = vertices[(axis + 1) % m_axisCount];
                g_drawPool.addFilledTriangle(centerPoint, Point(static_cast<int>(std::lround(a.x)), static_cast<int>(std::lround(a.y))),
                                             Point(static_cast<int>(std::lround(b.x)), static_cast<int>(std::lround(b.y))), layer.fillColor);
            }
        }

        if (layer.lineColor.aF() > Fw::MIN_ALPHA) {
            for (int axis = 0; axis < m_axisCount; ++axis)
                drawLine(vertices[axis], vertices[(axis + 1) % m_axisCount], layer.lineWidth, layer.lineColor);
        }
    }
}

void UIRadarChart::onStyleApply(const std::string_view styleName, const OTMLNodePtr& styleNode)
{
    UIWidget::onStyleApply(styleName, styleNode);

    for (const OTMLNodePtr& node : styleNode->children()) {
        if (node->tag() == "axis-count")
            setAxisCount(node->value<int>());
        else if (node->tag() == "ring-count")
            setRingCount(node->value<int>());
        else if (node->tag() == "grid-color")
            setGridColor(node->value<Color>());
        else if (node->tag() == "grid-width")
            setGridWidth(node->value<int>());
    }
}
