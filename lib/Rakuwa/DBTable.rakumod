use Rakuwa::Conf;
use Rakuwa::View;
use Template6;
use Rakuwa::DB;
use HTML::Escape;

class Rakuwa::DBTable is Rakuwa::View {
    has $.id is rw = "";
    has Str $.title is rw = '';
    has $.template is rw = 'db-table';
    has $.request is rw;
    has @.path is rw = ();

    has $.auto_order is rw = True;

    has $.pagination is rw = True;
    has $.total-count is rw = 0;
    has $.offset is rw= 0;
    has $.nav_pages is rw = 5;

    has $.key_column is rw = '';
    has $.hidde_key_column is rw = True;

    has $.columns-attributes is rw = { :class("text-center") };
    has @.columns-align is rw = ();
    has %.columns-labels is rw = {};

    has %.detail is rw = {
        :Tr({
            :params_a({:class("zl_row_a")}),
            :params_b({:class("zl_row_b")}),
        }),
        :td({
            :params({}),
        }),
    };
    has %.no_data_td is rw = {
        :class("zl_no_data"),
        :align("center"),
    };

    has %.labels is rw = {
        :page_of("Page _PAGE_ of _OF_"),
        :no_data("No records found"),
        :link_up("&uarr;"),
        :link_down("&darr;"),
        :next_page("&raquo;"),
        :previous_page("&laquo;"),
        :number_of_rows("_NUMBER_ records"),
    };

    has @.data;
    has %.query is rw = {
        :select("*"),
        :from(""),
        :where(""),
        :order_by(""),
        :group_by(""),
        :limit(30),
    };

    has %.links is rw = {
        :location(""),
        :transit_params({}),
    };

    has %.table-attrs is rw = {
        :class("table table-striped table-sm m-0"),
        :width("100%"),
        :align("center"),
        :cellspacing("0"),
    };
    has $.caption is rw = '';
    has @.columns = [];
    has $.rows_details = '';


    method get-data () {
        if (@.data) {
            # Data already fetched, no need to fetch again
            return;
        }

        # Fetch data from the database based on the SQL query
        if ($.request.query-hash{'rdbt_offset'}:exists) {
            $.offset = Int($.request.query-hash{'rdbt_offset'});
            say "Offset set to: ", $.offset;
        }
        my $sql = "SELECT " ~ %.query<select> ~ " FROM " ~ %.query<from>;

        if %.query<where>:exists {
            $sql ~= " WHERE " ~ %.query<where>;
        }

        if %.query<group_by>:exists {
            $sql ~= " GROUP BY " ~ %.query<group_by>;
        }

        if %.query<order_by>:exists {
            $sql ~= " ORDER BY " ~ %.query<order_by>;
        }

        $sql ~= " LIMIT " ~ (%.query<limit> // 30);
        if $.offset > 0 {
            $sql ~= " OFFSET " ~ $.offset;
        }

        my $statement = $.db.db.prepare($sql);
        my $result = $statement.execute;
        @!columns = $result.names;
        @!data = $result.hashes;

        if ($.pagination) {
            my $sql-count = "SELECT COUNT(*) FROM " ~ %.query<from>;
            if %.query<where>:exists {
                $sql-count ~= " WHERE " ~ %.query<where>;
            }
            if %.query<group_by>:exists {
                $sql-count ~= " GROUP BY " ~ %.query<group_by>;
            }

            $.total-count = $.db.query($sql-count).value;
        }

        $.free;
    }

    method get-columns (-->Str) {
        # Prepare the columns for the table
        my $columns-str = '';
        for @!columns -> $col {
            if ($col eq $.key_column && $.hidde_key_column) {
                # Skip hidden key column
                next;
            }
            my $label;
            if (%.columns-labels{$col}:exists) {
                $label = %.columns-labels{$col};
            } else {
                $label = $col;
                $label = $label.subst(/_/,' ', :g).subst(/^\w/, { $/.uc });
            }
            $columns-str ~= "<th ";
            for $.columns-attributes.kv -> $key, $value {
                $columns-str ~= "$key=\"$value\" ";
            }

            $columns-str ~= ">" ~ $label ~ "</th>";
        }
        return $columns-str;
    }

    method get-details (-->Str) {
        # Prepare the details for the table rows
        if @!data.elems == 0 {
            # No data available, return no data message
            my $colspan = @!columns.elems;
            if $.hidde_key_column {
                $colspan--;
            }
            %.no_data_td<colspan> = $colspan;
            return self._tag('tr', {},
                                 self._tag('td', %.no_data_td, %.labels<no_data>)
                                 );
        }

        my $details-str = '';
        for @!data -> $row {
            my $row-class = ($.rows_details eq 'alternate') ?? 'zl_row_a' !! 'zl_row_b';
            my $index = 0;
            my $tds-str = '';
            for @!columns -> $col {
                next  if ($col eq $.key_column && $.hidde_key_column);
                $tds-str ~= self._tag('td', { :align($.columns-align[$index] // 'left') }, ($row{$col} // ''));
                $index++;
            }

            my $location = %.links<location>;
            if $location {
                $details-str ~= self._tag('tr', {
                    :class($row-class ~ ' c-pointer'),
                    :onclick("window.location.href='" ~ $location ~ "/" ~ $row{$.key_column} ~ "'"),
                }, $tds-str);
            } else {
                $details-str ~= self._tag('tr', { :class($row-class) }, $tds-str);
            }
        }
        return $details-str;
    }

    method get-table-start () {
        # Prepare the table start HTML
        if (%.links<location>) {
            %.table-attrs<class> ~= " table-hover";
        }
        return self._tag('table', %.table-attrs, '',:onlystart);
    }

    method get-pagination ( --> Hash) {
        my %pagination := {
            :records(""),
            :page(""),
            :pages("")
        };

        # return early if pagination is not enabled or no records found
        if (! $.pagination || $.total-count == 0) {
            return %pagination;
        }

        my $limit = %.query<limit> // 30;
        my $pagination-str = '';
        my $current-page = Int($.offset / $limit);
        my $total-pages = Int($.total-count / $limit) + 1;
        my $path = $.request.path;

        if ($current-page > 0) {
            $pagination-str ~= self._tag('li', { :class('page-item') },
                    self._tag('a', {
                    :href($path ~ '?rdbt_offset=' ~ ($current-page - 1) * $limit),
                    :class('page-link'),
                }, %.labels<previous_page>));
        }
        $pagination-str ~= self._tag('li', { :class('page-item disabled') },
            self._tag('a',{:href('#'), :class('page-link')}, ($current-page + 1))
                );
        if ($current-page < $total-pages - 1) {
            $pagination-str ~= self._tag('li', { :class('page-item') },
                self._tag('a', {
                    :href($path ~ '?rdbt_offset=' ~ ($current-page + 1) * $limit),
                    :class('page-link'),
                }, %.labels<next_page>));
        }

        %pagination<pages> = $pagination-str;
        %pagination<records> = %.labels<number_of_rows>.subst(/_NUMBER_/, @.data.elems);
        %pagination<page> = %.labels<page_of>.subst(/_PAGE_/, $current-page + 1).subst(/_OF_/, $total-pages);

        return %pagination;
    }

    method render (%vars={}) {
        # Prepare the view for rendering

        self.get-data();

        $.status = 200;
        my $template = $.template;
        my $TT = Template6.new(:include-path([%conf<template><template_dir> ~ '/']));
        $TT.add-path(%conf<template><template_dir> ~ '/');

        $.content = $TT.process($.template,
                :title($.title),
                :msg(self.get-msgs),
                :table-start(self.get-table-start),
                :caption($.caption),
                :columns(self.get-columns),
                :details(self.get-details),
                :pagination($.get-pagination),
                :debug(%conf<debug>)
                );

    }

    method set-column-label(Str $column, Str $label) {
        # Set a custom label for a specific column
        %.columns-labels{$column} = $label;
    }
}
