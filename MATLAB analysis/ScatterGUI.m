function ScatterGUI(summary_Table, timepoint)
    % Проверка существования таблицы
    if ~exist('summary_Table', 'var') || ~istable(summary_Table)
        error('Input must be a table named summary_Table');
    end
    
    % Проверка наличия timepoint
    if ~exist('timepoint', 'var')
        error('Input timepoint must be provided');
    end
    
    % Проверка, что timepoint - число или строка
    if ~isnumeric(timepoint) && ~ischar(timepoint) && ~isstring(timepoint)
        error('timepoint must be a number or string');
    end

    % Проверка наличия необходимых столбцов
    required_columns = {'area_m2', 'confidence'};
    if ~all(ismember(required_columns, summary_Table.Properties.VariableNames))
        error('summary_Table must contain columns: area_m2, confidence');
    end

    % Проверка размера таблицы
    if size(summary_Table, 1) == 0
        error('summary_Table is empty');
    end

    % Создание главного окна GUI
    fig = figure('Name', sprintf('Plot with Cut-off (Timepoint: %s [h])', string(timepoint)), ...
                 'Position', [100, 100, 1200, 600]); 

    % Извлечение данных из таблицы
    x = summary_Table.area_m2;
        % x_max = max(summary_Table.area_m2);
    y = summary_Table.confidence;
    f = summary_Table.confidence; % f-data совпадает с y-data
    class = summary_Table.class;

    % Фильтрация данных по морфотипам
    idx_monococci = ismember(class, 'monococci');
    idx_diplococci = ismember(class, 'diplococci');
    idx_tetracocci = ismember(class, 'tetracocci');

    % Данные для каждого морфотипа
    x_mono = x(idx_monococci); % area_m2
    y_mono = y(idx_monococci); % confidence
    f_mono = f(idx_monococci); % confidence
    x_diplo = x(idx_diplococci); % area_m2
    y_diplo = y(idx_diplococci); % confidence
    f_diplo = f(idx_diplococci); % confidence
    x_tetra = x(idx_tetracocci); % area_m2
    y_tetra = y(idx_tetracocci); % confidence
    f_tetra = f(idx_tetracocci); % confidence

    % Создание осей для графика
    ax1 = axes('Parent', fig, 'Position', [0.1, 0.55, 0.4, 0.35]); % Scatter plot
    ax2 = axes('Parent', fig, 'Position', [0.57, 0.55, 0.4, 0.35]); % Box plot
   
    % Инициализация графиков
    initial_cutoff = 0;
    initial_marker_size = 5;

    % Первый график Scatter plot: График для всех морфотипов
    hold(ax1, 'on');
    scatter_handle_mono = scatter(ax1, x_mono(f_mono >= initial_cutoff & ~isnan(f_mono)), ...
                                 y_mono(f_mono >= initial_cutoff & ~isnan(f_mono)), ...
                                 initial_marker_size, 'o', 'filled', 'MarkerFaceColor', 'b', ...
                                 'DisplayName', 'Monococci');
    scatter_handle_diplo = scatter(ax1, x_diplo(f_diplo >= initial_cutoff & ~isnan(f_diplo)), ...
                                 y_diplo(f_diplo >= initial_cutoff & ~isnan(f_diplo)), ...
                                 initial_marker_size, 'o', 'filled', 'MarkerFaceColor', 'r', ...
                                 'DisplayName', 'Diplococci'); 
    scatter_handle_tetra = scatter(ax1, x_tetra(f_tetra >= initial_cutoff & ~isnan(f_tetra)), ...
                                 y_tetra(f_tetra >= initial_cutoff & ~isnan(f_tetra)), ...
                                 initial_marker_size+10, 'o', 'filled', 'MarkerFaceColor', 'k', ...
                                 'DisplayName', 'Tetracocci');
    hold(ax1, 'off');
    title(ax1, sprintf('Confidence vs Area (Timepoint: %s [h])', string(timepoint)));
    xlabel(ax1, 'object area [\mum^2]');
    ylabel(ax1, 'confidence');
    grid(ax1, 'on');
    axis square
    legend(ax1, 'show', 'Location', 'northeast');
    set(ax1, 'XLim', [0 7], 'YLim', [0 1]);

    % % Фиксация диапазона осей для scatter plot
    % valid_idx = ~isnan(x) & ~isnan(y);
    % set(ax1, 'XLim', [min(x(valid_idx)) max(x(valid_idx))], ...
    %          'YLim', [min(y(valid_idx)) max(y(valid_idx))]);
    
    % Второй график Box plot
    boxplot_handle = boxplot(ax2, [x_mono(f_mono >= initial_cutoff & ~isnan(f_mono)); ...
                                   x_diplo(f_diplo >= initial_cutoff & ~isnan(f_diplo)); ...
                                   x_tetra(f_tetra >= initial_cutoff & ~isnan(f_tetra))], ...
                            [repmat({'Monococci'}, sum(f_mono >= initial_cutoff & ~isnan(f_mono)), 1); ...
                             repmat({'Diplococci'}, sum(f_diplo >= initial_cutoff & ~isnan(f_diplo)), 1); ...
                             repmat({'Tetracocci'}, sum(f_tetra >= initial_cutoff & ~isnan(f_tetra)), 1)], ...
                            'Colors', 'brk', 'Symbol', 'r+'); % Без отображения выбросов
    title(ax2, sprintf('Area Distribution by Morphotype (Timepoint: %s [h])', string(timepoint)));
    xlabel(ax2, 'Morphotype');
    ylabel(ax2, 'object area [\mum^2]');
    grid(ax2, 'on');
    set(ax2, 'YLim', [0 7]);

    % % Фиксация диапазона осей для box plot
    % set(ax2, 'YLim', [min(x(valid_idx)) max(x(valid_idx))]);

    % Создание ползунка для управления cut-off
    slider_cutoff = uicontrol('Parent', fig, ...
                             'Style', 'slider', ...
                             'Position', [100, 40, 600, 20], ...
                             'Min', 0, 'Max', 1, 'Value', initial_cutoff, ...
                             'Callback', @slider_callback);

    % Создание метки для cut-off
    uicontrol('Parent', fig, ...
              'Style', 'text', ...
              'Position', [350, 70, 100, 20], ...
              'String', sprintf('Confidence Cut-off: %.2f', initial_cutoff));


    % Создание текстового поля для вывода количества точек, процентов и статистики (n, average, median, std)
    stats_text = uicontrol('Parent', fig, ...
                            'Style', 'text', ...
                            'Position', [700, 200, 400, 100], ...
                            'String', '', ...
                            'HorizontalAlignment', 'left', ...
                            'FontSize', 10);

    % Определение вложенной функции update_stats_text
    function update_stats_text(cutoff)
        % Подсчёт количества точек для каждого морфотипа
        idx_mono = f_mono >= cutoff & ~isnan(f_mono);
        idx_diplo = f_diplo >= cutoff & ~isnan(f_diplo);
        idx_tetra = f_tetra >= cutoff & ~isnan(f_tetra);

        n_mono = sum(idx_mono);
        n_diplo = sum(idx_diplo);
        n_tetra = sum(idx_tetra);
        n_total = n_mono + n_diplo + n_tetra;

        % Расчёт процентов
        if n_total > 0
            perc_mono = (n_mono / n_total) * 100;
            perc_diplo = (n_diplo / n_total) * 100;
            perc_tetra = (n_tetra / n_total) * 100;
        else
            perc_mono = 0;
            perc_diplo = 0;
            perc_tetra = 0;
        end

        % Расчёт статистики для каждого морфотипа
        if n_mono > 0
            avg_mono = mean(x_mono(idx_mono), 'omitnan');
            med_mono = median(x_mono(idx_mono), 'omitnan');
            std_mono = std(x_mono(idx_mono), 'omitnan');
        else
            avg_mono = NaN;
            med_mono = NaN;
            std_mono = NaN;
        end

        if n_diplo > 0
            avg_diplo = mean(x_diplo(idx_diplo), 'omitnan');
            med_diplo = median(x_diplo(idx_diplo), 'omitnan');
            std_diplo = std(x_diplo(idx_diplo), 'omitnan');
        else
            avg_diplo = NaN;
            med_diplo = NaN;
            std_diplo = NaN;
        end

        if n_tetra > 0
            avg_tetra = mean(x_tetra(idx_tetra), 'omitnan');
            med_tetra = median(x_tetra(idx_tetra), 'omitnan');
            std_tetra = std(x_tetra(idx_tetra), 'omitnan');
        else
            avg_tetra = NaN;
            med_tetra = NaN;
            std_tetra = NaN;
        end



        % Shapiro–Wilk test
        % test of normality - whether data are normally distributed
        % функция swtest скачена с https://uk.mathworks.com/matlabcentral/fileexchange/13964-shapiro-wilk-and-shapiro-francia-normality-tests
        alfa = 0.05;
        [H_mono, pValue_mono, SWstatistic_mono] = swtest(x_mono(idx_mono), alfa);
        [H_diplo, pValue_diplo, SWstatistic_diplo] = swtest(x_diplo(idx_diplo), alfa);
        [H_tetra, pValue_tetra, SWstatistic_tetra] = swtest(x_tetra(idx_tetra), alfa);
        

        
        % Формирование текста для counts_text
        stats_str = sprintf(['Total points: %d\n', ...
                              'Monococci: %d (%.1f%%), Avg=%.3f (' char(956) 'm^2), Med=%.3f, Std=%.3f\n', ...
                              'SW-test: W=%.3f, P=%.3f, H=%.1f\n', ...
                              'Diplococci: %d (%.1f%%), Avg=%.3f (' char(956) 'm^2), Med=%.3f, Std=%.3f\n', ...
                              'SW-test: W=%.3f, P=%.3f, H=%.1f\n', ...
                              'Tetracocci: %d (%.1f%%), Avg=%.3f (' char(956) 'm^2), Med=%.3f, Std=%.3f\n', ...
                              'SW-test: W=%.3f, P=%.3f, H=%.1f\n'], ...
                              n_total, ...
                              n_mono, perc_mono, avg_mono, med_mono, std_mono, ...
                              SWstatistic_mono, pValue_mono, H_mono, ...
                              n_diplo, perc_diplo, avg_diplo, med_diplo, std_diplo, ...
                              SWstatistic_diplo, pValue_diplo, H_diplo, ...
                              n_tetra, perc_tetra, avg_tetra, med_tetra, std_tetra, ...
                              SWstatistic_tetra, pValue_tetra, H_tetra); 

        % Обновление counts_text
        set(stats_text, 'String', stats_str);
    end

    % Обновление текстовых полей при инициализации
    update_stats_text(initial_cutoff);
    
    % Вложенная функция для обработки событий ползунка cut-off
    function slider_callback(~, ~)
        % Получение текущего значения ползунка
        cutoff = slider_cutoff.Value;

        % Обновление метки
        uicontrol('Parent', fig, ...
                  'Style', 'text', ...
                  'Position', [350, 70, 150, 20], ...
                  'String', sprintf('Confidence Cut-off: %.2f', cutoff));

        % Обновление scatter plot
        % Обновление графика для monococci
        idx_mono = f_mono >= cutoff;
        set(scatter_handle_mono, 'XData', x_mono(idx_mono), 'YData', y_mono(idx_mono));
        
        % Обновление графика для diplococci
        idx_diplo = f_diplo >= cutoff;
        set(scatter_handle_diplo, 'XData', x_diplo(idx_diplo), 'YData', y_diplo(idx_diplo));

        % Обновление графика для tetracocci
        idx_tetra = f_tetra >= cutoff;
        set(scatter_handle_tetra, 'XData', x_tetra(idx_tetra), 'YData', y_tetra(idx_tetra));

        % Обновление box plot
        delete(boxplot_handle); % Удаляем старый box plot
        boxplot_handle = boxplot(ax2, [x_mono(idx_mono); x_diplo(idx_diplo); x_tetra(idx_tetra)], ...
                                [repmat({'Monococci'}, sum(idx_mono), 1); ...
                                 repmat({'Diplococci'}, sum(idx_diplo), 1); ...
                                 repmat({'Tetracocci'}, sum(idx_tetra), 1)], ...
                                'Colors', 'brk', 'Symbol', 'r+');
        title(ax2, 'Area Distribution by Morphotype');
        xlabel(ax2, 'Morphotype');
        ylabel(ax2, 'object area [\mum^2]');
        grid(ax2, 'on');
        set(ax2, 'YLim', [0 7]);

        % Обновление текстовых полей
        update_stats_text(cutoff);
    end
end
