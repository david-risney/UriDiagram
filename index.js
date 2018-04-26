document.addEventListener("DOMContentLoaded", e => {
    const diagramArea = document.getElementById("diagramArea");
    const uriArea = document.getElementById("uriArea");
    const errorArea = document.getElementById("errorArea");

    if (uriArea.textContent.length === 0 && document.location.search.length > 0) {
        uriArea.textContent = document.location.search.substr(1);
    }
    else {
        uriArea.textContent = "https://user:pass@example.com:8080/path/parts?a=b&c=d#fragment";
    }
    uriAreaChanged();

    function clearError() {
        errorArea.textContent = "";
    }

    function handleError(error) {
        errorArea.textContent = error.message;
    }

    function renderDiagram(inEntries) {
        function spaces(count) {
            if (count > 0) {
                return Array(count).fill(" ", 0, count).join("");
            }
            return "";
        }

        function dashes(count) {
            if (count > 0) {
                return Array(count).fill("-", 0, count).join("");
            }
            return "";
        }

        function inRange(min, value, max) { return min <= value && value <= max; }

        const entries = inEntries.map(e => { 
            const entry = {
                name: e.n,
                start: e.l.start.column - 1,
                end: e.l.end.column - 1,
            };

            entry.length = entry.end - entry.start;
            entry.nameLength = entry.name.length;
            entry.maxLength = Math.max(entry.length, entry.nameLength);

            entry.nameStart = Math.max(Math.floor(entry.start + ((entry.length / 2) - (entry.nameLength / 2))), 0);
            entry.minStart = Math.min(entry.start, entry.nameStart);

            entry.nameEnd = entry.nameStart + entry.nameLength;
            entry.maxEnd = Math.max(entry.end, entry.nameEnd);

            return entry;
        }).sort((left, right) => {
            return right.minStart !== left.minStart ? 
                left.minStart - right.minStart :  // sort first by starting position then by length
                right.maxLength - left.maxLength; // reverse sort to have longest at front
        });

        let lines = [];

        let currentLineTop = { start: Infinity, end: -Infinity, value: "" };
        let currentLineBottom = { start: Infinity, end: -Infinity, value: "" };
        for (let count = 0; count < entries.length; ++count) {
            if (inRange(Math.min(currentLineTop.start, currentLineBottom.start), entries[count].minStart, Math.max(currentLineTop.end - 1, currentLineBottom.end - 1)) ||
                inRange(Math.min(currentLineTop.start - 1, currentLineBottom.start - 1), entries[count].maxEnd, Math.max(currentLineTop.end, currentLineBottom.end)))
            {
                lines.push(currentLineTop.value);
                lines.push(currentLineBottom.value);

                currentLineTop = { start: Infinity, end: -Infinity, value: "" };
                currentLineBottom = { start: Infinity, end: -Infinity, value: "" };
            }

            currentLineTop.start = Math.min(entries[count].nameStart, currentLineTop.start);
            currentLineTop.end = Math.max(entries[count].nameEnd, currentLineTop.end);
            currentLineTop.value += spaces(entries[count].nameStart - currentLineTop.value.length);
            currentLineTop.value += entries[count].name;

            currentLineBottom.start = Math.min(entries[count].start, currentLineBottom.start);
            currentLineBottom.end = Math.max(entries[count].end, currentLineBottom.end);
            currentLineBottom.value += spaces(entries[count].start - currentLineBottom.value.length);
            currentLineBottom.value += "/" + dashes(entries[count].length - 2) + "\\";
        }

        if (currentLineTop.start !== Infinity) {
            lines.push(currentLineTop.value);
            lines.push(currentLineBottom.value);
        }

        return lines.join("\n");
    }

    function uriAreaChanged() {
        try {
            clearError();
            const result = diagramUriParser.parse(uriArea.textContent.trim());
            diagramArea.textContent = renderDiagram(result);
        }
        catch (e) {
            handleError(e);
        }
    }

    uriArea.addEventListener("keyup", uriAreaChanged);
    uriArea.addEventListener("clear", uriAreaChanged);


});
